provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require File.join(provider_path, 'vsanmgmt.api')
require File.join(provider_path, 'vsanapiutils')

Puppet::Type.type(:vc_vsan).provide(:vc_vsan, :parent => Puppet::Provider::Vcenter) do
  @doc = "Enable / Disable VSAN property."

  def create
    Puppet.debug("Configuring VSAN ")
    if resource[:dedup]
      data_efficiency_spec = RbVmomi::VIM::VsanDataEfficiencyConfig.new
      data_efficiency_spec.compressionEnabled = resource[:dedup]
      data_efficiency_spec.dedupEnabled = resource[:dedup]
    end

    vsan_cluster_config = RbVmomi::VIM::VsanClusterConfigInfo.new
    default_config_spec = RbVmomi::VIM::VsanClusterConfigInfoHostDefaultInfo.new
    default_config_spec.autoClaimStorage = resource[:auto_claim]

    vsan_cluster_config.defaultConfig = default_config_spec
    vsan_cluster_config.enabled = true

    reconfig_spec = RbVmomi::VIM::VimVsanReconfigSpec.new
    reconfig_spec.dataEfficiencyConfig = data_efficiency_spec if resource[:dedup]
    reconfig_spec.vsanClusterConfig = vsan_cluster_config
    reconfig_spec.modify = true

    vsan_task = vsan.vsanClusterConfigSystem.VsanClusterReconfig(:cluster => cluster, :vsanReconfigSpec => reconfig_spec ).onConnection(vim)
    vsan_task.wait_for_completion
    raise("Failed to enable / configure VSAN for cluster #{resource[:cluster]} with message: #{vsan_task.info.error.inspect}") unless vsan_task.info.state == "success"
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
    if resource[:dedup].nil?
      vsan_cluster_config.enabled
    else
      vsan_cluster_config.enabled &&
        vsan_cluster_config.dataEfficiencyConfig.dedupEnabled.to_s == resource[:dedup].to_s
    end
  end

  def datacenter
    @dc ||= vim.serviceInstance.find_datacenter(resource[:datacenter])
  end

  def cluster
    datacenter.find_compute_resource(resource[:cluster])
  end

  def vsan
    @vsan ||= vim.vsan
  end

  def vsan_cluster_config
    vsan.vsanClusterConfigSystem.VsanClusterGetConfig(:cluster => cluster)
  end

end
