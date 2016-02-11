# Copyright (C) 2016 VMware, Inc.
require 'set'
require 'pathname'

vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'

Puppet::Type.type(:vc_host_group).provide(:vc_host_group, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for Host Groups used for VM-Host rules. http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.cluster.HostGroup.html"

  def exists?
    host_group
  end

  def create
    Puppet.debug "#{self} Creating Host group"
    reconfigureComputeResource( :add )
  end

  def destroy
    Puppet.debug "#{self} Destroying Host group"
    reconfigureComputeResource( :remove )
  end

  def hosts
    # Configured is Hosts that currently reside under the existing Host group
    configured  = host_group.host.map { |host| host.name }
    # Discovered is Hosts that exist in the cluster matching the requested names
    discovered = host_list(resource[:hosts]).map { |host| host.name }
    Puppet.debug "#{self} Host Group '#{resource[:name]}' includes '#{configured.inspect}' matching requested '#{discovered.inspect}'"
    if host_group.host.map { |host| host._ref } == host_list(resource[:hosts]).map { |host| host._ref }
      resource[:hosts]
    else
      configured
    end
  end

  def hosts=(value)
    Puppet.debug "#{self} Updating Host group to #{host_list(resource[:hosts]).map { |host| host.name }}"
    reconfigureComputeResource( :edit )
  end

  def reconfigureComputeResource(operation)
    spec = {:operation => operation}
    if operation == :remove
      spec[:removeKey] = host_group.name
    else
      spec[:info] = RbVmomi::VIM::ClusterHostGroup(
        :name => resource[:name],
        :host   => host_list(resource[:hosts])
      )
    end

    group_spec = RbVmomi::VIM::ClusterGroupSpec( spec )
    spec = RbVmomi::VIM::ClusterConfigSpecEx(:groupSpec => [ group_spec ])
    Puppet.debug "#{self} Reconfiguring cluster '#{cluster.name}' with #{spec.inspect}'"
    cluster.ReconfigureComputeResource_Task(:spec => spec, :modify => true).wait_for_completion
  end

  private

  def host_group
    @host_group ||= 
      begin 
        host_group = cluster.configurationEx.group.find {|group| group.name == @resource[:name]}
        raise Puppet::Error, "#{self} :: A ClusterGroup of another type already exists matching '#{resource[:name]}'. You cannot have host groups and vm groups share the same name space." unless host_group.nil? || host_group.class.to_s == 'ClusterHostGroup'
        Puppet.debug "#{self} returned ClusterHostGroup '#{host_group.inspect}'"
        host_group
      end
  end

  def host_list(host_names)
    @hosts ||= 
      begin
        matches = []
        host_names.each do |name|
          cluster.host.each { |host| matches << host if host.name =~ /#{name}/ }
        end
        matches.uniq { |host| host._ref}
      end
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource) or raise Puppet::Error, "#{self} cluster not found at path '#{resource[:path]}'."
  end
end

