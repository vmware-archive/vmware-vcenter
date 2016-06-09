# Copyright (C) 2013 VMware, Inc.
require 'set'

require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

Puppet::Type.type(:vc_dvportgroup).provide(:vc_dvportgroup, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Distributed Virtual Portgroup"

  def create
    dvsw_path = @resource[:dvswitch_path]
    dvpg_name = @resource[:dvportgroup_name]
    unless dvswitch
      fail "Missing dvswitch '#{dvsw_path}': can't create portgroup '#{dvpg_name}"
    end

    @creating = true
    @create_message ||= []
    # fetch properties from resource
    map.leaf_list.each do |leaf|
      p = leaf.prop_name
      unless (value = @resource[p]).nil?
        self.send("#{p}=".to_sym, value)
        @create_message << "#{leaf.full_name} => #{value.inspect}"
      end
    end
    # can't leave for flush's ReconfigurePortgroup_Task
    # because create needs AddDVPortgroup_Task
    spec = flush_prep
    dvswitch.CreateDVPortgroup_Task(:spec => spec).wait_for_completion
    @flush_required = false

  end

  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  def destroy
    if dvpg = dvportgroup
      dvpg.Destroy_Task.wait_for_completion
    end
  end

  def exists?
    dvportgroup
  end

  map ||= PuppetX::VMware::Mapper.new_map('DVPortgroupConfigSpecMap')

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

  def flush_prep
    # dvswitch requires matching configVersion
    unless @creating
      config_should[:configVersion] = config_is_now[:configVersion]
    end

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

  def flush
    return unless @flush_required
    spec = flush_prep
    dvportgroup.ReconfigureDVPortgroup_Task(:spec => spec).wait_for_completion
  end

  # not private: used by insyncInheritablePolicy
  define_method(:map) do 
    @map ||= map
  end

  private

  def properties_rcvd
    @properties_rcvd ||= Set.new
  end

  def properties_reqd
    @properties_reqd ||= Set.new([:type])
  end

  def config_is_now
    @config_is_now ||= 
        (@creating ? {} : map.annotate_is_now(dvportgroup.config))
  end

  def config_should
    @config_should ||= {}
  end

  def datacenter
    @datacenter ||= 
      begin
        dvswitch_parent = Pathname.new(resource[:dvswitch_path]).parent.to_s
        dc = vim.serviceInstance.find_datacenter(dvswitch_parent)
      end
    Puppet.debug "found datacenter: #{@datacenter.class} '#{@datacenter.name}'" if @datacenter
    @datacenter
  end

  def dvswitch
    @dvswitch ||= 
      begin
        name = Pathname.new(resource[:dvswitch_path]).basename.to_s
        if datacenter
          datacenter.networkFolder.children.select{|n|
            n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
          }.
          find{|d| d.name == name}
        else
          nil
        end
      end
    Puppet.debug "found dvswitch: #{@dvswitch.class} '#{@dvswitch.name}'" if @dvswitch
    @dvswitch
  end

  def dvportgroup
    @dvportgroup ||=
      begin
        name = @resource[:dvportgroup_name]
        dvs_name = dvswitch.config.name
        pg =
          if datacenter
            pg = 
              datacenter.networkFolder.children.select{|n|
                n.class == RbVmomi::VIM::DistributedVirtualPortgroup
              }.
              find_all{|pg| pg.name == name}.
              tap{|all| @dvportgroup_list = all}.
              find{|pg| pg.config.distributedVirtualSwitch.name == dvs_name}
            if pg.nil? && (@dvportgroup_list.size != 0)
              owner = @dvportgroup_list.first.config.distributedVirtualSwitch.name
              fail "dvportgroup '#{name}' owned by dvswitch '#{owner}', "\
                   "is not available for '#{dvs_name}'"
            end
            pg
          else
            nil
          end
      end
    Puppet.debug "found dvportgroup: #{@dvportgroup.class} '#{@dvportgroup.name}'" if @dvportgroup
    @dvportgroup
  end

end
