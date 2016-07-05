# Copyright (C) 2013 VMware, Inc.
require 'set'

require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent

require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

Puppet::Type.type(:esx_vmknic).provide(:esx_vmknic, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages ESXi vmknics."

  def create
    @creating = true
    esxihostname = @resource[:esxi_host]
    vmknicname = @resource[:nicname]
    unless esxhost
      fail "Could not locate esxi host '#{esxihostname}': can not create vmknic '#{vmknicname}'"
    end
    # Make sure the desired vmknic name is the next one to be created, since api autonames them.
    previous_nic = "vmk" + (vmknicname.delete('vmk').to_i - 1).to_s
    unless (find_vmknic previous_nic)
      fail "Attempting to create '#{vmknicname}', but it is not the next available vmknic"
    end
    @create_message ||= []

    # fetch properties from resource
    map.leaf_list.each do |leaf|
      p = leaf.prop_name
      unless (value = @resource[p]).nil?
        self.send("#{p}=".to_sym, value)
        @create_message << "#{leaf.full_name} => #{value.inspect}"
      end
    end
    nic_spec = flush_prep
    # :portgroup should be '' if working against dvswitch, else give it a value
    esxhost.configManager.networkSystem.AddVirtualNic(:portgroup => @resource[:portgroup], 
      :nic => nic_spec)
    @flush_required = false
  end

  def destroy
    esxhost.configManager.networkSystem.RemoveVirtualNic(:device => @resource[:nicname])
  end

  map ||= PuppetX::VMware::Mapper.new_map('HostVirtualNicSpecMap')

  map.leaf_list.each do |leaf|
    define_method(leaf.prop_name) do
      value = PuppetX::VMware::Mapper::munge_to_tfsyms.call(
        PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      )
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set(config_should, leaf.path_should, value)
      properties_rcvd.add leaf.prop_name
      properties_reqd.merge leaf.requires
      @flush_required = true
    end
  end

  alias get_dvswitchname dvswitchname
  def dvswitchname
    v = get_dvswitchname
    unless v.nil?
      v = all_dvswitch.find{|s| s.uuid == v}.name
    end
    v
  end

  alias set_dvswitchname dvswitchname=
  def dvswitchname= dvs_name
    v = all_dvswitch.find{|s| s.name == dvs_name}.uuid
    set_dvswitchname v
  end

  alias get_dvportgroupname dvportgroupname
  def dvportgroupname
    v = get_dvportgroupname
    unless v.nil?
      v = get_dvportgroup_by_key(v).name
    end
    v
  end

  alias set_dvportgroupname dvportgroupname=
  def dvportgroupname= dvpg_name
    v = get_dvportgroup_by_name(dvpg_name).key
    set_dvportgroupname v
  end

  def flush_prep
    ###################################################################
    # special for esx_vmknic: when switching from dhcp to static while 
    # keeping the same ip address and netmask, since they don't change, 
    # they must be fetched from the resource
    if (properties_rcvd.include? :dhcp) && (@resource[:dhcp] == :false)
      properties_reqd.merge([:ip_address, :subnet_mask])
    end
    #
    ###################################################################

    # To change some properties, the API requires others that may not have 
    # changed. If not, they must be fetched from the type. When additional 
    # properties are fetched, new items may be added to required_properties,
    # so iteration is required.
    Puppet.debug "requiring: #{@properties_rcvd.sort.inspect} were received"
    Puppet.debug "requiring: #{@properties_reqd.sort.inspect} initially required"
    properties_rcvd_old = Set.new
    while properties_rcvd != properties_rcvd_old
      properties_rcvd_old = properties_rcvd.dup
      properties_reqd.subtract properties_rcvd
      unless properties_reqd.empty?
        Puppet.debug "requiring: #{@properties_reqd.sort.inspect} are required"
        # properties_reqd may change
        # properties_rcvd will change unless resource has no value for property
        properties_reqd.dup.each{|p| 
          self.send "#{p}=".to_sym, @resource[p] unless @resource[p].nil?
        }
      end
    end
    properties_reqd.subtract properties_rcvd
    Puppet.debug "requiring: #{@properties_rcvd.sort.inspect} were received"
    unless @properties_reqd.empty?
      fail "required properties missing - #{@properties_reqd.inspect}"
    end

    # create RbVmomi objects with properties in place of hashes with keys
    Puppet.debug "'is_now' is #{config_is_now.inspect}'}"
    Puppet.debug "'should' is #{config_should.inspect}'}"
    spec = map.objectify config_should
    Puppet.debug "'object' is #{spec.inspect}'}"
    spec
  end
 
  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  def exists?
    vmknic
  end

  def flush
    return unless @flush_required
    nic = flush_prep
    esxhost.configManager.networkSystem.UpdateVirtualNic(:device => @resource[:nicname], 
      :nic => nic)
  end

  # not private: used by insyncInheritablePolicy
  define_method(:map) do 
    @map ||= map
  end
  
  private

  def properties_rcvd
    @properties_rcvd ||= Set.new
  end

  # The required properties set.  
  # Add items here if they MUST be present in the inputs.
  def properties_reqd
    @properties_reqd ||= Set.new()
  end

  def config_is_now
    @config_is_now ||= (@creating ? {} : map.annotate_is_now(vmknic.spec))
  end

  def config_should
    @config_should ||= {}
  end

  def esxhost
    @esxhost ||= vim.searchIndex.FindByDnsName(:dnsName => @resource[:esxi_host],
      :vmSearch => false)
  end

  def find_parent_of_class (child, target_class)
    if child.respond_to?('parent')
      if child.parent.class == target_class
        child.parent
      else
        find_parent_of_class(child.parent, target_class)
      end
    else
      nil
    end
  end

  def datacenter
    @datacenter ||= find_parent_of_class(esxhost, RbVmomi::VIM::Datacenter)
  end

  def get_dvportgroup_by_name (dvpg_name)
    dvswitch.portgroup.find {|pg| pg.config.name == dvpg_name}
  end

  def get_dvportgroup_by_key (dvpg_key)
    dvswitch.portgroup.find {|pg| pg.config.key == dvpg_key}
  end

  def get_portgroup
    esxhost.configManager.networkSystem.networkConfig.portgroup.find {|pg| 
      pg[:spec].name == @resource[:standardportgroupname]}
  end

  def all_dvswitch
    @all_dvswitch ||= datacenter.networkFolder.children.select{|n| 
      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch}
  end

  def dvswitch
    @dvswitch ||= 
      begin
        all_dvswitch.find{|s| s.name == @resource[:dvswitchname]}
      end
    @dvswitch
  end

  def find_vmknic (nic_name)
    esxhost.configManager.networkSystem.networkConfig.vnic.find {|n| n[:device] == nic_name}
  end

  def vmknic
    @vmknic ||= find_vmknic @resource[:nicname]
  end

end



