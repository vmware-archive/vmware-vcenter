provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vsan_network).provide(:vv_vsan, :parent => Puppet::Provider::Vcenter) do
  @doc = "Enable / Disable VSAN property of vmkernel for each host in the cluster"

  def create
    host_spec = []
    vsan_hosts.each do |vsan_host|
      cluster_host = vsan_host.hostSystem
      vmk = vsan_vmkernel(cluster_host)
      next if vsan_host_existing_vmk(vsan_host).include?(vmk)

      network_info = RbVmomi::VIM::VsanHostConfigInfoNetworkInfo.new(
          :port => [RbVmomi::VIM::VsanHostConfigInfoNetworkInfoPortConfig.new(:device => vmk)])

      host_spec << RbVmomi::VIM::VsanHostConfigInfo.new(:hostSystem => cluster_host, :networkInfo => network_info)
    end
    spec = RbVmomi::VIM::ClusterConfigSpecEx.new(:vsanHostConfigSpec => host_spec)
    task_ref = cluster.ReconfigureComputeResource_Task(:modify => 'true', :spec => spec);
    task_ref.wait_for_completion
    raise("Failed to configure VSAN for host #{host.name}") unless task_ref.info.state == "success"
  end

  def destroy
  end

  def exists?
    false
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

  def vsan_hosts
    cluster.configurationEx.vsanHostConfig
  end

  def cluster_hosts
    ( cluster.host || [] )
  end

  def vsan_host_existing_vmk(vsan_host)
    vsan_ports = ( vsan_host.networkInfo.port || [] )
    vsan_ports.collect { |x| x.device}
  end

  def vsan_vmkernel(host)
    nicmgr = host.configManager.virtualNicManager.info.netConfig
    nicmgr.each do |n|
      n.candidateVnic.each do |nic|
        return nic.device if nic.portgroup == resource[:vsan_port_group_name]
      end
    end
    raise("Failed to find vmkernel for portgroup : #{resource[:vsan_port_group_name]}")
  end


end
