# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_datacenter).provide(:vc_datacenter, :parent => Puppet::Provider::Vcenter) do

  @doc = "Manages vCenter Datacenters."

  def create
    vmfolder.CreateDatacenter(:name => basename)
  end

  def destroy
    dc = locate(@resource[:path], RbVmomi::VIM::Datacenter)
    dc.Destroy_Task.wait_for_completion
  end

  def exists?
    locate(@resource[:path], RbVmomi::VIM::Datacenter)
  end
end

