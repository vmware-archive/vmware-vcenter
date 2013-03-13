# Copyright (C) 2013 VMware, Inc.
require 'set'

require 'pathname' # WORK_AROUND #14073 and #7788
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:vc_dvportgroup).provide(:vc_dvportgroup, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Distributed Virtual Portgroup"

  def create
    if dvswitch
      @resource.properties.each do |p|
        self.send "#{p.name}=".to_sym, @resource[p.name] unless 
            @resource[p.name].nil?
      end
    else
      path = @resource[:dvswitch_path]
      name = @resource[:dvportgroup_name]
      fail "Missing dvswitch '#{path}': can't create portgroup '#{name}"
    end
    # let flush do the rest
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

    require 'ruby-debug'; debugger

    # create RbVmomi objects with properties in place of hashes with keys
    Puppet.debug "'is_now' is #{config_is_now.inspect}'}"
    Puppet.debug "'should' is #{config_should.inspect}'}"
    spec = map.objectify config_should
    Puppet.debug "'object' is #{spec.inspect}'}"
    require 'ruby-debug' ; debugger
    spec
  end

  def flush
    return unless @flush_required
    spec = flush_prep
    dvswitch.ReconfigureDVPortGroup_Task(:spec => spec).wait_for_completion
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
        map.annotate_is_now dvportgroup.config
  end

  def config_should
    @config_should ||= {}
  end

  require 'pathname'

  def datacenter
    @datacenter ||= 
      begin
        dvswitch_parent = Pathname.new(resource[:dvswitch_path]).parent
        dc = vim.serviceInstance.find_datacenter(dvswitch_parent)
      end
    require 'ruby-debug' ; debugger
    Puppet.debug "found datacenter: #{@datacenter.class} '#{@datacenter.name}'" if @datacenter
    @datacenter
  end

  def dvswitch
    @dvswitch ||= 
      begin
        if datacenter
          dvswitch_name = @resource[:dvswitch_name]
          datacenter.networkFolder.children.select{|n|
            n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
          }.
          find{|d| d.name == dvswitch_name}
        else
          nil
        end
      end
    require 'ruby-debug' ; debugger
    Puppet.debug "found dvswitch: #{@dvswitch.class} '#{@dvswitch.name}'" if @dvswitch
    @dvswitch
  end

  def dvportgroup
    @dvportgroup ||=
      begin
        if dvswitch
          dvswitch.uplinkPortgroup.find do |pg| 
            pg.name == @resource[:dvportgroup_name]
          end
        else
          nil
        end
      end
    require 'ruby-debug' ; debugger
    Puppet.debug "found dvportgroup: #{@dvportgroup.class} '#{@dvportgroup.name}'" if @dvportgroup
    @dvportgroup
  end

end
