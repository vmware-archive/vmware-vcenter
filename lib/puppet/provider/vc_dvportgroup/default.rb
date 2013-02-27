# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_dvportgroup).provide(:vc_dvportgroup, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage vCenter Distributed Virtual Portgroups."

  def create
    datacenter = @resource[:path].split('/')[1]
    dc = vim.serviceInstance.find_datacenter(datacenter)
    dswitch = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch }

    spec = RbVmomi::VIM::DVPortgroupConfigSpec.new

    spec.name = basename
    spec.type = "earlyBinding"

    spec.defaultPortConfig = RbVmomi::VIM::VMwareDVSPortSetting.new
    spec.defaultPortConfig.vlan = RbVmomi::VIM::VmwareDistributedVirtualSwitchVlanIdSpec.new
    spec.defaultPortConfig.vlan.vlanId = @resource[:vlanid]
    spec.defaultPortConfig.vlan.inherited = false

    dswitch.map {|s|
      s.AddDVPortgroup_Task(:spec => [spec])
    }

  end

  def destroy
    dc = vim.serviceInstance.find_datacenter(@resource[:path].split('/')[1])
    dvportgroups = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::DistributedVirtualPortgroup }
    dvportgroups.find{ |d| d.name == basename }.Destroy_Task.wait_for_completion
  end

  def exists?
    #dc = vim.serviceInstance.find_datacenter(parent)
    dc = vim.serviceInstance.find_datacenter(@resource[:path].split('/')[1])
    dvportgroups = dc.networkFolder.children.select {|n| n.class == RbVmomi::VIM::DistributedVirtualPortgroup }
    dvportgroups.find{ |d| d.name == basename }
  end

end

