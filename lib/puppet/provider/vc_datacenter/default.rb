require 'lib/puppet/provider/vcenter'

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
    result = locate(@resource[:path])
    result.is_a? RbVmomi::VIM::Datacenter
  end
end

