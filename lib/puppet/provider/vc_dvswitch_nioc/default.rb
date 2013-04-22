# Copyright (C) 2013 VMware, Inc.

require 'pathname' # WORK_AROUND #14073 and #7788
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'

Puppet::Type.type(:vc_dvswitch_nioc).provide( :vc_dvswitch_nioc, 
                     :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Distributed Virtual Switch "\
         "Network Resource Management (NIOC)"

  def network_resource_management_enabled
    dvswitch.config.networkResourceManagementEnabled ? :true : :false
  end

  def network_resource_management_enabled= value
    dvswitch.EnableNetworkResourceManagement(:enable => value)
  end

  private

  def dvswitch
    @dvswitch ||= begin
                    dc = vim.serviceInstance.find_datacenter(parent)
                    dvswitches = dc.networkFolder.children.select {|n|
                      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
                    }
                    dvswitches.find{|d| d.name == basename}
                  end
    fail "dvswitch not found at #{path}" unless @dvswitch
    @dvswitch
  end

end
