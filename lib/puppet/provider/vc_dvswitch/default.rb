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

  # XXX lifted from previous version - check
  def create
    dc = vim.serviceInstance.find_datacenter(parent)
    spec = RbVmomi::VIM::DVSCreateSpec.new
    spec.configSpec = RbVmomi::VIM::DVSConfigSpec.new
    spec.configSpec.name = basename
    spec.configSpec.uplinkPortgroup = [basename]
    dc.networkFolder.CreateDVS_Task(:spec => spec)
  end

  # XXX lifted from previous version - check
  def destroy
    @dvswitch = nil
    dc = vim.serviceInstance.find_datacenter(parent)
    dvswitches = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch}
    dvswitches.find{|d| d.name == basename}.Destroy_Task.wait_for_completion
  end

  # XXX lifted from previous version - check
  def exists?
    dvswitch
=begin
    dc = vim.serviceInstance.find_datacenter(parent)
    dvswitches = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch}
    dvswitches.find{|d| d.name == basename}
=end
  end

  map ||= PuppetX::VMware::Mapper.new_map('VMwareDVSConfigSpecMap')

  map.leaf_list.each do |leaf|
    define_method(leaf.prop_name) do
      value = PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      value = :true  if TrueClass  === value
      value = :false if FalseClass === value
      value
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set(config_should, leaf.path_should, value)
      properties_received.add leaf.prop_name
      properties_required.merge leaf.requires
    end
  end

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

  def flush_prep
    # dvswitch requires matching configVersion
    config_should[:configVersion] = config_is_now[:configVersion]

    # To change some properties, the API requires others that may not 
    # have changed. If not, they must be fetched from the type.
    Puppet.debug "requiring: #{@properties_received.inspect} were received"
    properties_required.subtract properties_received
    unless properties_required.empty?
      Puppet.debug "requiring: #{@properties_required.inspect} are required"
      properties_required.each{|p| self.send "#{p}=".to_sym, @resource[p]}
    end

    # create RbVmomi objects with properties in place of hashes with keys
    Puppet.debug "'is_now' is #{config_is_now.inspect}'}"
    Puppet.debug "'should' is #{config_should.inspect}'}"
    config_object = 
      map.objectify config_should
    Puppet.debug "'object' is #{config_object.inspect}'}"
    config_object
  end

  def flush
    return unless exists?
    spec = flush_prep
    task = dvswitch.ReconfigureDvs_Task(
      :spec => spec
    ).wait_for_completion
  end

  private

  define_method(:map) do 
    @map ||= map
  end

  def properties_received
    @properties_received ||= Set.new
  end

  def properties_required
    @properties_required ||= Set.new
  end

  def config_is_now
    @config_is_now ||= 
        map.annotate_is_now dvswitch.config
  end

  def config_should
    @config_should ||= {}
  end

  def dvswitch
    @dvswitch ||= unless @dvswitch
                    dc = vim.serviceInstance.find_datacenter(parent)
                    dvswitches = dc.networkFolder.children.select {|n|
                      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
                    }
                    dvswitches.find{|d| d.name == basename}
                  end
    Puppet.debug "found dvswitch: #{@dvswitch.class} '#{@dvswitch.name}'" if @dvswitch
    @dvswitch
  end

end
