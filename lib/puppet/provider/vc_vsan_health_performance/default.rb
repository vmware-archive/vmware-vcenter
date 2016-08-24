provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require File.join(provider_path, 'vsanmgmt.api')
require File.join(provider_path, 'vsanapiutils')

Puppet::Type.type(:vc_vsan_health_performance).provide(:vc_vsan_health_performance, :parent => Puppet::Provider::Vcenter) do
  @doc = "Enable / Disable VSAN Health Performannce Service."

  def create
    Puppet.debug("Configuring VSAN performance service")
    vsan.vsanPerformanceManager.VsanPerfCreateStatsObjectTask(:cluster => cluster).onConnection(vim).wait_for_completion
  end

  def destroy
    Puppet.debug("De-Configuring VSAN performance service")
    begin
      vsan.vsanPerformanceManager.VsanPerfDeleteStatsObject(:cluster => cluster)
    rescue => ex
      Puppet.debug("Exception encountered while disabling VSAN Health Services with message: %s" % [ex.message])
    end
  end

  def exists?
    status = JSON.parse(vsan.vsanClusterHealthSystem.VsanHealthGetClusterStatus(:cluster => cluster))
    Puppet.debug("VSAN Health Servce Status: #{status}")

    group_health = vsan.vsanPerformanceManager.VsanPerfQueryClusterHealth(:cluster => cluster)[0].groupHealth
    if resource[:ensure] == :present
      group_health != "green" ? false : true
    elsif resource[:ensure] == :absent
      group_health != "unknown"
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

end
