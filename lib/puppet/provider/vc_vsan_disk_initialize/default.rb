provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require File.join(provider_path, 'vsanmgmt.api')

Puppet::Type.type(:vc_vsan_disk_initialize).provide(:vc_vsan_disk_initialize, :parent => Puppet::Provider::Vcenter) do
  @doc = "Initialize VSAN Disk for cluster node"

  def create
    cluster_hosts.each do |host|
      next if disk_configured?(host)
      initialize_disk(host)
    end
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

  def disk_configured?(host)
    diskm = RbVmomi::VIM::VimClusterVsanVcDiskManagementSystem(hsconn, 'vsan-disk-management-system')
    disk_mappings = diskm.QueryDiskMappings(:host => host)
    !disk_mappings.empty?
  end

  def hsconn
    @hsconn = RbVmomi::VIM.new(:host => vim.host,
                               :port => 443,
                               :insecure => true,
                               :ns => 'urn:vim25',
                               :ssl => true,
                               :rev => "6.0",
                               :path => '/vsanHealth' )
    @hsconn.cookie = vim.cookie
    @hsconn.debug = vim.debug
    @hsconn
  end

  def initialize_disk(host)
    vsansys = host.configManager.vsanSystem
    vsandisks =  vsansys.QueryDisksForVsan()
    ssd = []
    nonssd = []
    vsandisks.each do |vsandisk|
      next if vsandisk.disk.displayName.match(/usb/i)
      next  if vsandisk.state == "inUse"
      if vsandisk.disk.ssd
        ssd.push(vsandisk.disk)
      else
        nonssd.push(vsandisk.disk)
      end
    end
    return true if ssd.empty?
    diskspec = RbVmomi::VIM::VimVsanHostDiskMappingCreationSpec.new()
    diskspec.cacheDisks = ssd
    diskspec.capacityDisks = nonssd
    diskspec.creationType = "hybrid"
    diskspec.host = host
    diskm = RbVmomi::VIM::VimClusterVsanVcDiskManagementSystem(hsconn, 'vsan-disk-management-system')
    task_ref = diskm.InitializeDiskMappings(:spec => diskspec)
    task_ref.wait_for_completion
    raise("Failed to initialize disk for host #{host.name}") unless task_ref.info.state == "success"
  end



end
