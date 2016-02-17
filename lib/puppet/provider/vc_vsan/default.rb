provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vsan).provide(:vc_vsan, :parent => Puppet::Provider::Vcenter) do
  @doc = "Enable / Disable VSAN property."

  def create
    vsan_config = RbVmomi::VIM::VsanClusterConfigInfoHostDefaultInfo.new(
        'autoClaimStorage' => resource[:auto_claim]
    )
    vsan_config_spec = RbVmomi::VIM::VsanClusterConfigInfo.new(
        'enabled' => true,
        'defaultConfig' => vsan_config
    )
    cluster_config_spec = RbVmomi::VIM::ClusterConfigSpecEx.new('vsanConfig' => vsan_config_spec)
    task_ref = cluster.ReconfigureComputeResource_Task({ 'spec' => cluster_config_spec, 'modify' => true}  )
    task_ref.wait_for_completion
    raise("Failed to enable VSAN for cluster #{resource[:cluster]}") unless task_ref.info.state == "success"

  end

  def destroy
    vsan_config_spec = RbVmomi::VIM::VsanClusterConfigInfo.new(
        'enabled' => false
    )
    cluster_config_spec = RbVmomi::VIM::ClusterConfigSpecEx.new('vsanConfig' => vsan_config_spec)
    task_ref = cluster.ReconfigureComputeResource_Task({ 'spec' => cluster_config_spec, 'modify' => true}  )
    task_ref.wait_for_completion
    raise("Failed to disable VSAN for cluster #{resource[:cluster]}") unless task_ref.info.state == "success"
  end

  def exists?
    cluster.configurationEx.vsanConfigInfo.enabled
  end

  def datacenter
    @dc ||= vim.serviceInstance.find_datacenter(resource[:datacenter])
  end

  def cluster
    datacenter.find_compute_resource(resource[:cluster])
  end

  private

  def vsan_config_info
    cluster.configurationEx.vsanConfigInfo
  end

end
