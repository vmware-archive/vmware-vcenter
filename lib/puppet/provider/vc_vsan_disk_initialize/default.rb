provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require File.join(provider_path, 'vsanmgmt.api')

Puppet::Type.type(:vc_vsan_disk_initialize).provide(:vc_vsan_disk_initialize, :parent => Puppet::Provider::Vcenter) do
  @doc = "Initialize VSAN Disk for cluster node"

  def create
    hosts_task_info = {}
    cluster_hosts.each do |host|
      if disk_configured?(host)
        Puppet.debug("Skipping disk Initialization for server #{host.name}")
        next
      else
        hosts_task_info[host.name] = []
        Puppet.debug("Initiating disk intialization for #server #{host.name}")
        hosts_task_info[host.name] = initialize_disk(host)
      end
    end

    while !hosts_task_info.keys.empty? do
      hosts_task_info.each do |host_name, task|
        Puppet.debug("Task status for host #{host_name} is #{task.info.state}")
        hosts_task_info.delete(host_name) if task.info.state != "running"
      end
      sleep(60) unless hosts_task_info.empty?
    end
  end

  def destroy
    if resource[:cleanup_hosts]
      cleanup_hosts_disk_group
    else
      cleanup_cluster_disk_group
    end
  end

  def host_system(host)
    cluster_hosts.find {|x| x.name == host}
  end

  def exists?
    resource[:ensure] != :present
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

  def disk_mappings(host)
    diskm = RbVmomi::VIM::VimClusterVsanVcDiskManagementSystem(hsconn, 'vsan-disk-management-system')
    diskm.QueryDiskMappings(:host => host)
  end

  def disk_configured?(host)
    disk_mappings = disk_mappings(host)
    !disk_mappings.empty?
  end

  def hsconn
    conn = RbVmomi::VIM.new(:host => vim.host,
                               :port => 443,
                               :insecure => true,
                               :ns => 'urn:vim25',
                               :ssl => true,
                               :rev => "6.0",
                               :path => '/vsanHealth' )
    conn.cookie = vim.cookie
    conn.debug = vim.debug
    conn
  end

  def initialize_disk(host)
    vsansys = host.configManager.vsanSystem
    vsandisks =  vsansys.QueryDisksForVsan()
    ssd = []
    nonssd = []
    # Sort disk based on the size
    vsandisks.sort! {|x| x.disk.capacity.block }
    vsandisks.each do |vsandisk|
      next if vsandisk.disk.displayName.match(/usb/i)
      next  if ["inUse", "ineligible"].include?(vsandisk.state)
      if vsandisk.disk.ssd
        ssd.push(vsandisk.disk)
      else
        nonssd.push(vsandisk.disk)
      end
    end
    return true if ssd.empty?
    diskspec = RbVmomi::VIM::VimVsanHostDiskMappingCreationSpec.new()

    case creation_type(nonssd)
      when "hybrid"
        diskspec.cacheDisks = ssd
        diskspec.capacityDisks = nonssd
        diskspec.creationType = "hybrid"
      when "allFlash"
        ssd.sort! {|x| x.capacity.block }
        diskspec.cacheDisks = [ssd[0]]
        diskspec.capacityDisks = ssd[1..ssd.size-1]
        diskspec.creationType = "allFlash"
    end
    diskspec.host = host
    diskm = RbVmomi::VIM::VimClusterVsanVcDiskManagementSystem(hsconn, 'vsan-disk-management-system')
    vsan_task = diskm.InitializeDiskMappings(:spec => diskspec)
    RbVmomi::VIM::Task(vim, vsan_task._ref )
  end

  def creation_type(non_ssd)
    non_ssd.size >= 1 ? "hybrid" : "allFlash"
  end


  def cleanup_cluster_disk_group
    cluster_hosts.each do |cluster_host|
      cleanup_disk_group(cluster_host)
    end
  end

  def cleanup_hosts_disk_group
    Puppet.debug("Cleanup hosts : #{resource[:cleanup_hosts]}")
    if resource[:cleanup_hosts].is_a?(String)
      host = host_system(resource[:cleanup_hosts])
      cleanup_disk_group(host)
    else
      resource[:cleanup_hosts].each do |input_host|
        host = host_system(input_host)
        cleanup_disk_group(host)
      end
    end
  end

  def cleanup_disk_group(host)
    vsansys = host.configManager.vsanSystem
    disk_mappings = vsan_query_disk(host)
    unless disk_mappings.empty?
      task_ref = vsansys.RemoveDiskMapping_Task(:mapping => disk_mappings )
      task_ref.wait_for_completion
      raise("Failed to cleanuo disk-grpup for host #{host.name}") unless task_ref.info.state == "success"
    end
  end

  def vsan_query_disk(host)
    vsan_mapping = []
    disk_mappings(host).each do |map|
      vsan_mapping << map.mapping
    end
    vsan_mapping
  end

end
