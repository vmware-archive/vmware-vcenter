#!/opt/puppet/bin/ruby
require "json"
require "rbvmomi"
require_relative "../lib/puppet_x/puppetlabs/transport/rbvmomi_patch" # Use patched library to workaround rbvmomi issues
require "trollop"
require "nokogiri"

opts = Trollop::options do
  opt :server, 'vcenter address', :type => :string, :required => true
  opt :port, 'vcenter port', :default => 443
  opt :username, 'vcenter username', :type => :string, :required => true
  opt :password, 'vcenter password', :type => :string, :default => ENV['PASSWORD']
  opt :timeout, 'command timeout', :default => 1800
  opt :community_string, 'dummy value for ASM, not used'
  opt :credential_id, 'dummy value for ASM, not used'
  opt :output, 'output facts to a file', :type => :string, :required => true
end
facts = {}

def collect_vcenter_facts(vim)
  inventory = collect_inventory(vim.serviceContent.rootFolder)
  name = vim.serviceContent.setting.setting.find{|x| x.key == 'VirtualCenter.InstanceName'}.value
  customization_specs = vim.serviceContent.customizationSpecManager.info.collect{|spec| spec.name}
  storage_profiles = (exiting_profiles(vim).collect {|x| x.name} || [])
  version = vim.serviceContent.about.version
  {
      :vcenter_name => name,
      :vcenter_version => version,
      :datacenter_count => @datacenter_count.to_s,
      :cluster_count => @cluster_count.to_s,
      :vm_count => @vm_count.to_s,
      :host_count => @host_count.to_s,
      :customization_specs => customization_specs.to_s,
      :storage_profiles => storage_profiles.to_json,
      :inventory => inventory.to_json
  }
end

def exiting_profiles(vim)
  profiles = []

  # vCenter 5.1 do not support Profile Based Management
  return profiles if Float(vim.rev) <= 5.1

  require "rbvmomi/pbm"
  pbm_obj = RbVmomi::PBM
  pbm = pbm_obj.connect(vim, :insecure=> true)

  pbm_manager = pbm.serviceContent.profileManager
  profileIds = pbm_manager.PbmQueryProfile(
      :resourceType => {:resourceType => "STORAGE"},
      :profileCategory => "REQUIREMENT"
  )

  if profileIds.length > 0
    profiles = pbm_manager.PbmRetrieveContent(:profileIds => profileIds)
  end
  profiles

rescue
  STDERR.puts("Failed to look up profiles: %s" % $!.to_s)
  profiles
end

def collect_inventory(obj, parent=nil)
  hash = collect_simple_inventory(obj, parent)
  case obj
    when RbVmomi::VIM::Folder
      obj.children.each { |resource| hash[:children] << collect_inventory(resource) }
    when RbVmomi::VIM::Datacenter
      @datacenter_count += 1
      vds_children = obj.networkFolder.children.find_all{|x| x.is_a?(RbVmomi::VIM::VmwareDistributedVirtualSwitch)}
      (obj.hostFolder.children + vds_children).each { |resource| hash[:children] << collect_inventory(resource) }
    when RbVmomi::VIM::ClusterComputeResource
      @cluster_count += 1
      obj.host.each { |host| hash[:children] << collect_inventory(host) }
      hash[:attributes] = collect_cluster_attributes(obj)
    when RbVmomi::VIM::ComputeResource
      #If ComputeResource but not ClusterComputeResource, it is a standalone host
      hash = collect_inventory(obj.host.first)
    when RbVmomi::VIM::HostSystem
      # Will skip collecting the host configuration if "config" object is nil
      if obj.config
        @host_count += 1
        hash[:attributes] = collect_host_attributes(obj)
        (obj.vm + obj.datastore + obj.network).each{ |vm| hash[:children] << collect_inventory(vm, obj)}
      end
    when RbVmomi::VIM::VirtualMachine
      @vm_count += 1
      hash[:attributes] = collect_vm_attributes(obj)
    when RbVmomi::VIM::Datastore
      hash[:attributes] = collect_datastore_attributes(obj, parent)
    when RbVmomi::VIM::VmwareDistributedVirtualSwitch
       hash[:attributes] = collect_distributed_switch_attributes(obj, parent)
       hash[:attributes]["hosts"] = obj.FetchDVPorts!.map {|d| d.proxyHost.name if d.proxyHost}.compact.uniq || []
       obj.portgroup.each {|portgroup| hash[:children] << collect_inventory(portgroup)}
    when RbVmomi::VIM::DistributedVirtualPortgroup
      hash[:attributes] = collect_vds_portgroup_attributes(obj, parent)
    when RbVmomi::VIM::Network
      hash[:attributes] = collect_portgroup_attributes(obj, parent)
    else
  end
  hash
end

def collect_simple_inventory(obj, parent=nil)
 {:name => obj.name, :id => obj._ref, :type => obj.class, :attributes => {}, :children => []}
end

def collect_cluster_attributes(obj)
  attributes = {}

  das_config = obj.configurationEx.dasConfig
  drs_config = obj.configurationEx.drsConfig
  vsan_config = obj.configurationEx.vsanConfigInfo

  attributes = { :das_config => {}, :drs_config => {}, :vsan_config => {}}

  attributes[:das_config][:enabled] = das_config.enabled
  attributes[:das_config][:failoverLevel] = das_config.failoverLevel
  attributes[:das_config][:hBDatastoreCandidatePolicy] = das_config.hBDatastoreCandidatePolicy
  attributes[:das_config][:admissionControlEnabled] = das_config.admissionControlEnabled

  attributes[:drs_config][:defaultVmBehavior] = drs_config.defaultVmBehavior
  attributes[:drs_config][:enableVmBehaviorOverrides] = drs_config.enableVmBehaviorOverrides
  attributes[:drs_config][:enabled] = drs_config.enabled

  attributes[:vsan_config][:enabled] = vsan_config.enabled
  attributes[:vsan_config][:auto_claim] = vsan_config.defaultConfig.autoClaimStorage

  attributes
end

def host_connected?(host)
  host.summary.runtime.connectionState == 'connected'
end

def collect_host_attributes(host)
  attributes = {}
  # For blades, there are 2 service tags from this data.  1 for chassis, and one for the blade itself, and there doesn't seem to be anything distinguishing the 2
  # Seems unreliable to rely on the ordering of the serviceTags, but the 2nd tag seems to always be the blade's tag
  service_tag_array = []
  if host.summary.hardware
    service_tag_array = host.summary.hardware.otherIdentifyingInfo
                          .select{|x| x.identifierType.key=='ServiceTag'}
                          .collect{|x| x.identifierValue}
  end
  #Sometimes vcenter inventory doesn't have the otherIdentifyingInfo populated as expected, so we try to get the data a different way in those cases
  if service_tag_array.empty? && host.summary.runtime.connectionState == 'connected'
    begin
      #Even though we can get a single service tag from this query, it adds a little amount of time to discovery, which could potentially become huge in big environments.
      service_tag_array = [host.esxcli.hardware.platform.get.SerialNumber]
    rescue
      STDERR.puts "Could not query host #{host.name} for service tag"
    end
  end
  attributes[:service_tags] = service_tag_array
  attributes[:os_ip_address] = host.config.network.vnic[0].spec.ip.ipAddress
  attributes[:host_ip_addresses] = host.config.network.vnic.map { |vnic| vnic.spec.ip.ipAddress }
  attributes[:host_virtual_nics] = collect_host_vmk_ips(host)
  attributes[:installed_software] = collect_host_vib_list(host) if host_connected?(host)
  attributes[:host_physical_nic] = collect_host_pnic_mac(host)
  attributes[:ntp_servers] = host.config.dateTimeInfo.ntpConfig.server
  host_config = get_host_config(host)
  if host_config
    attributes[:hostname] = host_config.network.dnsConfig.hostName
    attributes[:version] = host_config.product.version
    attributes[:productName] = host_config.product.licenseProductName
    attributes[:productVersion] = host_config.product.licenseProductVersion
    attributes[:maintenance_mode] = host.runtime.inMaintenanceMode
    attributes[:syslog] = host.configManager.advancedOption.setting.select { |x| x.key == "Syslog.global.logDir" }.first.value
  end
  attributes
end

def collect_host_vib_list(host)
  task = host.configManager.patchManager.ScanHostPatchV2_Task
  vib_list = []
  attempts = 1
  until task.info.state  == "success" || attempts > 6 do
    attempts += 1
    sleep 5
  end
  if task.info.state == "success" 
    xml_result = Nokogiri::XML(task.info[:result][:xmlResult])
    vib_list = xml_result.xpath("//vib-scan-data//id//text()").map(&:to_s)
  else
    STDERR.puts "Could not query host %s for installed software: Operation did not complete before timeout." % [host.name]
  end
  vib_list
rescue
  STDERR.puts "Could not query host %s for installed software: %s: %s" % [host.name, $!.class, $!.to_s]
end

def collect_host_vmk_ips(host)
  host_virtual_nic_array = host.config.network.vnic
  virtual_nic_ip_array = host_virtual_nic_array.map { |hv_nic| hv_nic[:spec][:ip][:ipAddress] }
end

def collect_host_pnic_mac(host)
  host.config.network.pnic.map { |pnic| {:device => pnic[:device], :mac => pnic[:mac] } }
end

def collect_datastore_attributes(ds, parent=nil)
  attributes = {}
  #There seems to be some cases where a datastore has no hosts.  Seems like a case of bad data, but we don't want to break on this either way
  unless ds.host.empty?
    #Have to go through many steps in order to get the iscsi name and the iscsi group IP.  All the data doesn't seem to be in one place
    # so we have to get a piece of data from one place, and match it up to a different place to get all the data we want.
    if parent
      host = ds.host.find{|host| host.key.name == parent.name}.key
    else
      host = ds.host.first.key
    end
    host_config = get_host_config(host)
    return attributes if host_config.nil?
    mount_info = host_config.fileSystemVolume.mountInfo.find{|x| x.volume.name == ds.name}
    attributes[:volume_name] = mount_info.volume.name
    # Capacity will be returned back in gigabytes
    attributes[:capacity] = mount_info.volume.capacity / 1024.0 / 1024.0 / 1024.0
    if mount_info.volume.is_a?(RbVmomi::VIM::HostNasVolume)
      attributes[:nfs_host] = mount_info.volume.remoteHost
      attributes[:nfs_path] = mount_info.volume.remotePath
    elsif mount_info.volume.is_a?(RbVmomi::VIM::HostVmfsVolume)
      scsi_lun_disk_name = mount_info.volume.extent.first.diskName
      attributes[:scsi_device_id] = scsi_lun_disk_name
      host_storage_device = host_config.storageDevice
      host_scsi_disk = host_storage_device.scsiLun.find{|lun| lun.canonicalName == scsi_lun_disk_name}
      unless host_scsi_disk.nil?
        attributes[:vendor] = (host_scsi_disk.vendor || '').strip
        scsi_lun_uuid = host_scsi_disk.uuid
        topology_targets = host_config.storageDevice.scsiTopology.adapter.collect do |adapter|
          adapter.target.find_all do |target|
            (target.transport.is_a?(RbVmomi::VIM::HostInternetScsiTargetTransport) ||
                target.transport.is_a?(RbVmomi::VIM::HostFibreChannelOverEthernetTargetTransport)) &&
                target.lun.find{|lun| lun.key.include?(scsi_lun_uuid)}
          end
        end.flatten
        unless topology_targets.empty?
          #List of topology targets will have largely the same information that's necessary, so we'll just check the first one
          transport = topology_targets.first.transport
          if transport.is_a?(RbVmomi::VIM::HostInternetScsiTargetTransport)
            iscsi_name = transport.iScsiName
            attributes[:iscsi_iqn] = iscsi_name
            address = ''
            host_storage_device.hostBusAdapter.each do |hba|
              if hba.respond_to?('configuredStaticTarget')
                target = hba.configuredStaticTarget.find{|target| target.iScsiName == iscsi_name}
                unless target.nil?
                  address = target.address
                  break
                end
              end
            end
            attributes[:iscsi_group_ip] = address
          elsif transport.is_a?(RbVmomi::VIM::HostFibreChannelOverEthernetTargetTransport)
            wwpn = transport.portWorldWideName.to_s(16)
            attributes[:fcoe_wwpn] = wwpn
          end
        end
      end
    end
  end
  attributes
end

# Getting the host configuration manager can take 1-2 seconds.  Each datastore querying it can add a large amount of time to the inventory.
# This method helps by giving a cached version of the configuration manager to save a lot of the query time for the same host
def get_host_config(host)
  @host_configs ||= {}
  @host_configs[host.name] ||= host.config
end

def collect_vm_attributes(vm)
  nics = vm.guest.net
  unless nics.nil?
    ip_list = nics.map { |this_nic| this_nic.ipAddress[0] }
  end
  unless vm.summary.storage.nil?
    disk_size_gb = (vm.summary.storage.committed + vm.summary.storage.uncommitted) / (1024 * 1024 * 1024)
  end
  {:template => vm.summary.config.template,
  :hostname => vm.summary.guest.hostName,
  :vm_ips => ip_list,
  :datastore => vm.datastore&.first&.name || "",
  :num_cpu => vm.summary.config.numCpu,
  :disk_size_gb => disk_size_gb,
  :memory_size_mb => vm.summary.config.memorySizeMB}
end

def collect_distributed_switch_attributes(obj, parent)
  active_uplinks = obj.config.defaultPortConfig.uplinkTeamingPolicy.uplinkPortOrder.activeUplinkPort || []
  standby_uplinks = obj.config.defaultPortConfig.uplinkTeamingPolicy.uplinkPortOrder.standbyUplinkPort || []
  uplinks = active_uplinks + standby_uplinks
  host_pnic_devices = obj.config.host.map do |host|
    { :host_id => host.config.host._ref, :devices => host.config.backing.pnicSpec.map { |pnic_spec| pnic_spec[:pnicDevice] }}
  end

  {:active_uplinks => active_uplinks, :standby_uplinks => standby_uplinks, :uplink_names => uplinks, :host_pnic_devices => host_pnic_devices}

end

def collect_vds_portgroup_attributes(portgroup, parent=nil)
  active_uplinks = portgroup.config.defaultPortConfig.uplinkTeamingPolicy.uplinkPortOrder.activeUplinkPort
  standby_uplinks = portgroup.config.defaultPortConfig.uplinkTeamingPolicy.uplinkPortOrder.standbyUplinkPort

  if parent
    hostIps = []
    host = parent
    vnic = host.config.network.vnic.select { |vnic| vnic.spec.distributedVirtualPort.portgroupKey == portgroup._ref unless vnic.spec.distributedVirtualPort.nil? }
    v = (vnic || []).first
    hostIps <<  v.spec.ip.ipAddress if v && v.spec && v.spec.ip && v.spec.ip.ipAddress
  else
    hostIps = portgroup.host.map do |host|
      next unless host.config
      vnic = host.config.network.vnic.select { |vnic| vnic.spec.distributedVirtualPort.portgroupKey == portgroup._ref unless vnic.spec.distributedVirtualPort.nil? }
      v = (vnic || []).first
      detail = v.spec.ip.ipAddress if v && v.spec && v.spec.ip && v.spec.ip.ipAddress
      detail
    end
  end

  default_response = {
    :active_uplinks => active_uplinks,
    :standby_uplinks => standby_uplinks,
    :host_ip_addresses => (hostIps || []).compact
  }
  return default_response unless portgroup.config.defaultPortConfig.vlan.respond_to?(:vlanId)

  vlan_id = portgroup.config.defaultPortConfig.vlan.vlanId
  return default_response unless vlan_id.is_a?(Integer)
  default_response[:vlan_id] = vlan_id
  default_response
end

def collect_portgroup_attributes(network_obj, parent)
  # In case ESXi server is in non-responding state then need to skip port-group information
  network_host = network_obj.host.select {|h| h.name == parent.name}.first
  return {} if network_host.summary.runtime.connectionState == "disconnected"

  return {} unless network_host.configManager
  return {} unless network_host.configManager.networkSystem.networkInfo

  network = network_host.configManager.networkSystem.networkInfo.portgroup.select { |x| x.spec.name == network_obj.name }

  vlan_id = network.first.spec.vlanId
  vswitch_name = network.first.spec.vswitchName

  return {} unless vlan_id.is_a?(Integer)

  {:vlan_id => vlan_id, :vswitch_name => vswitch_name}
end

begin
  @datacenter_count = 0
  @cluster_count = 0
  @host_count = 0
  @vm_count = 0

  Timeout.timeout(opts[:timeout]) do
    vim = RbVmomi::VIM.connect(:host=>opts[:server], :password=>opts[:password], :user=> opts[:username], :port=>opts[:port], :insecure=>true)
    facts = collect_vcenter_facts(vim).to_json
    vim.close if vim # close open connection
  end
rescue Timeout::Error
  puts "Timed out trying to gather inventory"
  exit 1
rescue Exception => e
  puts "#{e}\n#{e.backtrace.join("\n")}"
  exit 1
else
  if facts.empty?
    puts 'Could not get updated facts'
    exit 1
  else
    puts 'Successfully gathered inventory.'
    puts JSON.pretty_generate(JSON.parse(facts))
    File.write(opts[:output], facts)
  end
end
