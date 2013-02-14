# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_dvs).provide(:vc_dvs, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vCenter Distributed Virtual Switches."

  def create
    dc = vim.serviceInstance.find_datacenter(parent)
    spec = RbVmomi::VIM::DVSCreateSpec.new
    spec.configSpec = RbVmomi::VIM::DVSConfigSpec.new
    spec.configSpec.name = basename
    spec.configSpec.uplinkPortgroup = [basename]
    dc.networkFolder.CreateDVS_Task(:spec => spec)
  end

  def destroy
    dc = vim.serviceInstance.find_datacenter(parent)
    dvswitches = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch }
    dvswitches.find{ |d| d.name == basename }.Destroy_Task.wait_for_completion
  end

  def exists?
    dc = vim.serviceInstance.find_datacenter(parent)
    dvswitches = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch }
    dvswitches.find{ |d| d.name == basename }
  end

end

