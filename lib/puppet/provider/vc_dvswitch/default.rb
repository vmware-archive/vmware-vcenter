# Copyright (C) 2013 VMware, Inc.
require 'set'

require 'pathname' # WORK_AROUND #14073 and #7788
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
require File.join vmware_module.path, 'lib/puppet/property/vmware'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:vc_dvswitch).provide(:vc_dvswitch, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Distributed Virtual Switch"

  def create
    @creating = true
    @create_message ||= []
    # build the spec for CreateDVS_Task
    create_spec = RbVmomi::VIM::DVSCreateSpec.new
    create_spec.configSpec = RbVmomi::VIM::DVSConfigSpec.new
    create_spec.configSpec.name = basename
    if @dvswitch.nil? && resource[:vds_version]
      create_spec.productInfo = RbVmomi::VIM::DistributedVirtualSwitchProductSpec.new
      create_spec.productInfo.version = resource[:vds_version]
    end
    # find the network folder and invoke the task
    dc = vim.serviceInstance.find_datacenter(parent)
    task_create_dvs = dc.networkFolder.CreateDVS_Task(:spec => create_spec)
    task_create_dvs.wait_for_completion
    # now rename the default uplink portgroup so it's easy to find
    if task_create_dvs.info.state == 'success'
      @dvswitch = task_create_dvs.info.result
      @dvswitch.config.uplinkPortgroup.first.
        Rename_Task(:newName => "#{basename}-uplink-pg").wait_for_completion
      @create_message << "uplink portgroup renamed to \"#{basename}-uplink-pg\""
    end
    @flush_required = false
  end

  def create_message
    @create_message ||= []
    "created (#{@create_message.join "; "})"
  end

  def destroy
    @dvswitch = nil
    dc = vim.serviceInstance.find_datacenter(parent)
    dvswitches = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch}
    dvswitches.find{|d| d.name == basename}.Destroy_Task.wait_for_completion
  end

  def exists?
    dvswitch
  end

  map ||= PuppetX::VMware::Mapper.new_map('VMwareDVSConfigSpecMap')

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
    Puppet.debug "requiring: #{@properties_rcvd.inspect} were received"
    properties_rcvd_old = Set.new
    while properties_rcvd != properties_rcvd_old
      properties_rcvd_old = properties_rcvd.dup
      properties_reqd.subtract properties_rcvd
      unless properties_reqd.empty?
        Puppet.debug "requiring: #{@properties_reqd.inspect} are required"
        # properties_reqd may change
        # properties_rcvd will change unless resource has no value for property
        properties_reqd.dup.each{|p| 
          self.send "#{p}=".to_sym, @resource[p] unless @resource[p].nil?
        }
      end
    end
    properties_reqd.subtract properties_rcvd
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
    begin
      dvswitch.ReconfigureDvs_Task(:spec => spec).wait_for_completion
    rescue Exception => e
      if e.message.match(/AlreadyExists:/i)
        Puppet.debug('Host already added to DVS')
      else
        fail "#{e.message}"
      end
    end
  end


  # not private: used by insyncInheritablePolicy
  define_method(:map) do 
    @map ||= map
  end

  def mo_ref_by_name opts
    name = opts[:name]
    type = opts[:type]
    scope = opts[:scope] || :datacenter

    myfile = File.expand_path(__FILE__) + ":mo_ref_by_name"

    if type == VIM::HostSystem
      case scope
      when :datacenter
        product_spec = RbVmomi::VIM::DistributedVirtualSwitchProductSpec.new
        product_spec.version = host_version(name)
        list = vim.serviceInstance.content.
          dvSwitchManager.QueryCompatibleHostForNewDvs(
            :container => datacenter,
            :recursive => true,
              :switchProductSpec => product_spec
          )
        raise 'No ESX hosts compatible for DVS found' if list.size == 0
      else
        fail "#{myfile}: scope \"#{scope}\" unimplemented for #{type}"
      end
    elsif type == VIM::DistributedVirtualSwitch
      case scope
      when :dvswitch
        list = [dvswitch]
      when :datacenter
        list = datacenter.networkFolder.children.
          select{|child| child.class == type}
      else
        fail "#{myfile}: scope \"#{scope}\" unimplemented for #{type}"
      end
    elsif type == VIM::DistributedVirtualPortgroup
      case scope
      when :dvswitch
        list = dvswitch.portgroup
      when :datacenter
        list = datacenter.networkFolder.children.
          select{|child| child.class == type}
      else
        fail "#{myfile}: scope \"#{scope}\" unimplemented for #{type}"
      end
    elsif type == VIM::DistributedVirtualPort
        fail "#{myfile}: unimplemented for #{type}"
    else
        fail "#{myfile}: unimplemented for #{type}"
    end

    if list
      obj = list.find{|o| o.name == name}
      obj._ref unless obj.nil?
    else
      nil
    end
      
  end

  def fixup_is type, is, should
    # see comments for class VMware_Array_VIM_Object
    # in vmware_lib/lib/puppet/property/vmware.rb
    if type == VIM::DistributedVirtualSwitchHostMemberConfigSpec
      if config_is_now
        config_is_now.host.map{|element| element.config}
      else
        nil
      end
    else
      Puppet.notice "fixup_is: unexpected type #{type.inspect}" unless
        [
          VIM::NumericRange,
        ].include? type
      is
    end
  end

  private

  def properties_rcvd
    @properties_rcvd ||= Set.new
  end

  def properties_reqd
    @properties_reqd ||= Set.new
  end

  def config_is_now
    @config_is_now ||= 
        (@creating ? {} : map.annotate_is_now(dvswitch.config))
  end

  def config_should
    @config_should ||= {}
  end

  def datacenter
    @datacenter||= vim.serviceInstance.find_datacenter(parent)
  end

  def dvswitch
    @dvswitch ||= begin
                    dc = vim.serviceInstance.find_datacenter(parent)
                    dvswitches = dc.networkFolder.children.select {|n|
                      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
                    }
                    dvswitches.find{|d| d.name == basename}
                  end
    Puppet.debug "found dvswitch: #{@dvswitch.class} '#{@dvswitch.name}'" if @dvswitch
    @dvswitch
  end

  def host_version(host)
    @host ||= vim.searchIndex.FindByDnsName(:datacenter => datacenter , :dnsName => host, :vmSearch => false) or raise(Puppet::Error, "Unable to find the host '#{host}'")
    @host.summary.config.product.version
  end

end
