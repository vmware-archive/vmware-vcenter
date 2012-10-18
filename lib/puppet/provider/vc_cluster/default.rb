require 'lib/puppet/provider/vcenter'

Puppet::Type.type(:vc_cluster).provide(:vc_cluster, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Clusters."

  def create
    vmfolder.CreateClusterEx(:name => basename, :spec => {})
  end

  def destroy
    cluster = locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource)
    cluster.Destroy_Task.wait_for_completion
  end

  def exists?
    result = locate(@resource[:path])
    result.is_a? RbVmomi::VIM::ClusterComputeResource
  end
end

