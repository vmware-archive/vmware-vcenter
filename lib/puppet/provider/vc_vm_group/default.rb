# Copyright (C) 2016 VMware, Inc.
require 'set'
require 'pathname'

module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

Puppet::Type.type(:vc_vm_group).provide(:vc_vm_group, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for VM Groups used for VM-Host rules. http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.cluster.VmGroup.html"

  def exists?
    vm_group
  end

  def create
    Puppet.debug "#{self} Creating VM group"
    reconfigureComputeResource( :add )
  end

  def destroy
    Puppet.debug "#{self} Destroying VM group"
    reconfigureComputeResource( :remove )
  end

  def vms
    # Configured is VMs that currently reside under the existing VM group
    configured  = vm_group.vm.map { |vm| vm.name }
    # Discovered is VMs that exist in the cluster matching the requested names
    discovered = vm_list(resource[:vms]).map { |vm| vm.name }
    Puppet.debug "#{self} VM Group '#{resource[:name]}' includes '#{configured.inspect}' matching requested '#{discovered.inspect}'"
    if vm_group.vm.map { |vm| vm._ref } == vm_list(resource[:vms]).map { |vm| vm._ref }
      resource[:vms]
    else
      configured
    end
  end

  def vms=(value)
    Puppet.debug "#{self} Updating VM group to #{vm_list(resource[:vms]).map { |vm| vm.name }}"
    reconfigureComputeResource( :edit )
  end

  def reconfigureComputeResource(operation)
    spec = {:operation => operation}
    if operation == :remove
      spec[:removeKey] = vm_group.name
    else
      spec[:info] = RbVmomi::VIM::ClusterVmGroup(
        :name => resource[:name],
        :vm   => vm_list(resource[:vms])
      )
    end

    group_spec = RbVmomi::VIM::ClusterGroupSpec( spec )
    spec = RbVmomi::VIM::ClusterConfigSpecEx(:groupSpec => [ group_spec ])
    Puppet.debug "#{self} Reconfiguring cluster '#{cluster.name}' with #{spec.inspect}'"
    cluster.ReconfigureComputeResource_Task(:spec => spec, :modify => true).wait_for_completion
  end

  private

  def vm_group
    @vm_group ||= 
      begin 
        vm_group = cluster.configurationEx.group.find {|group| group.name == @resource[:name]}
        raise Puppet::Error, "#{self} :: A ClusterGroup of another type already exists matching '#{resource[:name]}'. You cannot have host groups and vm groups share the same name space." unless vm_group.nil? ||  vm_group.class.to_s == 'ClusterVmGroup'
        Puppet.debug "#{self} returned ClusterVmGroup '#{vm_group.inspect}'"
        vm_group
      end
  end

  def vm_list(vm_names)
    @vms ||= 
      begin  
        vms = find_vms(cluster, vm_names)
        vms.uniq { |vm| vm._ref}
      end
  end

  def find_vms(container, vm_names)
    vmview = vim.serviceContent.viewManager.CreateContainerView(
      recursive: true, container: container,
      type: ['VirtualMachine'])
    vm_obj = vmview.view.select { |vm| vm_names.include? vm.name }
    vmview.DestroyView
    vm_obj
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource) or raise Puppet::Error, "#{self} cluster not found at path '#{resource[:path]}'."
  end
end

