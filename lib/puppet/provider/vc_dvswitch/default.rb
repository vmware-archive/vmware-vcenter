# Copyright (C) 2013 VMware, Inc.
require 'set'

require 'pathname' # WORK_AROUND #14073 and #7788
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:vc_dvswitch).provide(:vc_dvswitch, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Distributed Virtual Switch"

  def create
    # build the spec for CreateDVS_Task
    create_spec = RbVmomi::VIM::DVSCreateSpec.new
    create_spec.configSpec = RbVmomi::VIM::DVSConfigSpec.new
    create_spec.configSpec.name = basename
    # find the network folder and invoke the task
    dc = vim.serviceInstance.find_datacenter(parent)
    task_create_dvs = dc.networkFolder.CreateDVS_Task(:spec => create_spec)
    task_create_dvs.wait_for_completion
    # now rename the default uplink portgroup so it's easy to find
    if task_create_dvs.info.state == 'success'
      @dvswitch = task_create_dvs.info.result
      @dvswitch.config.uplinkPortgroup.first.
        Rename_Task(:newName => "#{basename}-uplink-pg").wait_for_completion
    end
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

=begin
  # munge the list of member hosts returned by the API
  # - convert ManagedObjects to ManagedObjectReferences (mo_ref)
  # - sort array to allow consistent comparisons
  alias get_host_host host_host
  def host_host
    fail "this isn't how to get current host list"
    fail "and it may not even be useful to do so"
    v = get_host_host
    v = v.map{|host| host.name} if v.is_a? Array
    v
  end

  # change input host list from hostname to mo_ref
  # - look only in this dvswitch's datacenter
  alias set_host_host host_host=
  def host_host= host_list
    host_list = [host_list] unless host_list.is_a? Array
    dc = locate(@resource[:path], RbVmomi::VIM::Datacenter)
    mo_ref_list = []
    misses_list = []
    host_list.each do |host_name|
      host = vim.searchIndex.FindByDnsName(
        :datacenter => dc, :dnsName => host_name, :vmSearch => false)
      if host._ref
        mo_ref_list << host._ref
      else
        misses_list << host_name
      end
    end
    unless misses_list.empty?
      raise Puppet::Error, "requested hosts not in datacenter: #{misses_list.inspect}"
    end
    set_host_host mo_ref_list
  end
=end

  def flush_prep
    # dvswitch requires matching configVersion
    config_should[:configVersion] = config_is_now[:configVersion]

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
      fail "#{e.inspect}"
    end
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
    @properties_reqd ||= Set.new
  end

  def config_is_now
    @config_is_now ||= 
        map.annotate_is_now dvswitch.config
  end

  def config_should
    @config_should ||= {}
  end

  def dvswitch
    @dvswitch ||= begin
                    dc = vim.serviceInstance.find_datacenter(parent)
                    dvswitches = dc.networkFolder.children.select {|n|
                      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
                    }
                    dvswitches.find{|d| d.name == basename}
                  end
    require 'ruby-debug' ; debugger
    Puppet.debug "found dvswitch: #{@dvswitch.class} '#{@dvswitch.name}'" if @dvswitch
    @dvswitch
  end

end
