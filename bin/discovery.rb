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
@port_group_info = {}
@std_port_group_info = {}
@host_config = {}

def collect_vcenter_facts(vim)
  create_port_group_metadata(vim.serviceContent.rootFolder)
  create_datastore_metadata(vim.serviceContent.rootFolder)
  inventory = collect_inventory(vim.serviceContent.rootFolder)
  name = vim.serviceContent.setting.setting.find {|x| x.key == 'VirtualCenter.InstanceName'}.value
  customization_specs = vim.serviceContent.customizationSpecManager.info.collect {|spec| spec.name}
  storage_profiles = (exiting_profiles(vim).collect {|x| x.name} || [])
  version = vim.serviceContent.about.version
  build = vim.serviceContent.about.build
  {
      :vcenter_name => name,
      :vcenter_version => version,
      :vcenter_build => build,
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
  @host_config[host.name] ||= host.config
  if @host_config[host.name].network.vnic
    attributes[:os_ip_address] = @host_config[host.name].network.vnic[0].spec.ip.ipAddress if @host_config[host.name].network.vnic[0]
    attributes[:host_ip_addresses] = @host_config[host.name].network.vnic.map { |vnic| vnic.spec.ip.ipAddress }
  end
  attributes[:host_virtual_nics] = collect_host_vmk_ips(host)
  attributes[:host_physical_nic] = collect_host_pnic_mac(host)
  attributes[:ntp_servers] = @host_config[host.name].dateTimeInfo.ntpConfig.server

  if @host_config[host.name]
    attributes[:hostname] = @host_config[host.name].network.dnsConfig.hostName if @host_config[host.name].network.dnsConfig
    attributes[:version] = @host_config[host.name].product.version
    attributes[:productName] = @host_config[host.name].product.licenseProductName
    attributes[:productVersion] = @host_config[host.name].product.licenseProductVersion
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
  host_virtual_nic_array = @host_config[host.name].network.vnic
  host_virtual_nic_array.map { |hv_nic| hv_nic[:spec][:ip][:ipAddress] }
end

def collect_host_pnic_mac(host)
  @host_config[host.name].network.pnic.map { |pnic| {:device => pnic[:device], :mac => pnic[:mac] } }
end

def collect_datastore_attributes(ds, parent=nil)
  ds_info = @datastore_info
  attributes = {}

  if ds_info[ds.name] &&
    ds_info[ds.name]["hosts"] &&
    ds_info[ds.name]["hosts"].include?(parent.name)
    attributes = ds_info[ds.name]["attributes"]
  end

  attributes
end

# Getting the host configuration manager can take 1-2 seconds.  Each datastore querying it can add a large amount of time to the inventory.
# This method helps by giving a cached version of the configuration manager to save a lot of the query time for the same host
def get_host_config(host)
  @host_config ||= {}
  @host_config[host.name] ||= host.config
end

# MONKEY PATCH TO CACHE ALL host.config CALLS
RbVmomi::VIM::HostSystem.class_eval do
  alias :config_intercepted :config

  HOST_CONFIG_CACHE = {}

  def config
    HOST_CONFIG_CACHE[self.name] ||= begin
      config_intercepted
    end
  end
end

def collect_vm_attributes(vm)
  nics = vm.guest.net
  unless nics.nil?
    ip_list = nics.map { |this_nic| this_nic.ipAddress[0] }
  end

  vm_summary = vm.summary
  vm_summary_config = vm_summary.config
  vm_summary_storage = vm_summary.storage
  unless vm_summary_storage.nil?
    disk_size_gb = (vm_summary_storage.committed + vm_summary_storage.uncommitted) / (1024 * 1024 * 1024)
  end

  {:template => vm_summary_config.template,
  :hostname => vm_summary.guest.hostName,
  :vm_ips => ip_list,
  :datastore => vm.datastore&.first&.name || "",
  :num_cpu => vm_summary_config.numCpu,
  :disk_size_gb => disk_size_gb,
  :memory_size_mb => vm_summary_config.memorySizeMB}
end

def collect_distributed_switch_attributes(obj, parent)
  port_order = obj.config.defaultPortConfig.uplinkTeamingPolicy.uplinkPortOrder
  active_uplinks = port_order.activeUplinkPort || []
  standby_uplinks = port_order.standbyUplinkPort || []
  uplinks = active_uplinks + standby_uplinks
  host_pnic_devices = obj.config.host.map do |host|
    host_config = host.config
    { :host_id => host_config.host._ref, :devices => host_config.backing.pnicSpec.map { |pnic_spec| pnic_spec[:pnicDevice] }}
  end

  {:active_uplinks => active_uplinks, :standby_uplinks => standby_uplinks, :uplink_names => uplinks, :host_pnic_devices => host_pnic_devices}
end

def create_datastore_metadata(obj)
  datastore_info = {}
  obj.children.each do |dc|
    next unless dc.respond_to?(:datastore)

    dss = dc.datastore
    dss.each do |ds|
      attributes = {}
      datastore_name = ds.name
      datastore_info[datastore_name] ||= {}
      datastore_info[datastore_name]["hosts"] ||= []
      datastore_info[datastore_name]["hosts"].push(*ds.host.map {|k| k.key.name})
      next unless ds.host.first
      
      host = ds.host.first.key
      host_config = @host_config[host.name]
      next unless host_config

      next unless host_config.fileSystemVolume

      next unless host_config.fileSystemVolume.mountInfo

      mount_info = host_config.fileSystemVolume.mountInfo.find{|x| x.volume.name == ds.name}
      next unless mount_info

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
      datastore_info[ds.name]["attributes"] = attributes
    end
  end

  @datastore_info = datastore_info
end


def create_port_group_metadata(obj)
  obj.children.each do |dc|
    next unless dc.respond_to?(:networkFolder)

    dc.networkFolder.children.each do |network_obj|
      if network_obj.class == RbVmomi::VIM::DistributedVirtualPortgroup && RbVmomi::VIM::Network
        network_obj_config = network_obj.config

        uplink_port_order = network_obj_config.defaultPortConfig.uplinkTeamingPolicy.uplinkPortOrder
        active_uplinks = uplink_port_order.activeUplinkPort
        standby_uplinks = uplink_port_order.standbyUplinkPort
        portgroup_hosts_info = {network_obj.name => {"hosts_info" => {}, "uplinks" => {:active_uplinks => active_uplinks,
                                                                                       :standby_uplinks => standby_uplinks}}}
        default_port_config_vlan = network_obj_config.defaultPortConfig.vlan
        if default_port_config_vlan.respond_to?(:vlanId)
          portgroup_hosts_info[network_obj.name]["vlan_id"] = default_port_config_vlan.vlanId
        end

        network_obj.host.map do |host|
          @host_config[host.name] ||= host.config
          next unless @host_config[host.name]

          vnic = @host_config[host.name].network.vnic.select {|vnic| vnic.spec.distributedVirtualPort.portgroupKey == network_obj._ref unless vnic.spec.distributedVirtualPort.nil?}
          v = (vnic || []).first
          detail = v.spec.ip.ipAddress if v && v.spec && v.spec.ip && v.spec.ip.ipAddress

          portgroup_hosts_info[network_obj.name]["hosts_info"].merge!({host.name => detail})
          detail
        end
        teaming_policy = network_obj.config.defaultPortConfig.uplinkTeamingPolicy.policy.value
        portgroup_hosts_info[network_obj.name]["teaming_policy"] = teaming_policy
        portgroup_hosts_info[network_obj.name]["uplink"] = !!network_obj&.config&.uplink

        @port_group_info.merge!(portgroup_hosts_info)
      elsif network_obj.class == RbVmomi::VIM::Network
        portgroup_hosts_info = {network_obj.name => {"hosts_info" => {}}}
        detail = []
        network_obj.host.map do |host|
          @host_config[host.name] ||= host.config
          next unless @host_config[host.name]

          port_groups = host.configManager.networkSystem.networkInfo.portgroup
          port_groups.each do |pg|
            detail.push(:name => pg.spec.name, :vlan_id => pg.spec.vlanId, :vswitch => pg.spec.vswitchName)
          end
          portgroup_hosts_info[network_obj.name]["hosts_info"].merge!({host.name => detail})
          detail
        end
        @std_port_group_info.merge!(portgroup_hosts_info)
      end
    end
  end
end

def collect_vds_portgroup_attributes(portgroup, parent = nil)
  port_group_name = portgroup.name
  portgroup_data = @port_group_info[port_group_name] || {"uplinks" => {}, "uplink" => false}
  portgroup_data["uplinks"] ||= {}

  default_response = portgroup_data["uplinks"].merge(:host_ip_addresses => [])
                       .merge("teaming_policy" => portgroup_data["teaming_policy"])
                       .merge("uplink" => portgroup_data["uplink"])
  return default_response unless portgroup_data["hosts_info"]

  host_ips = []
  if parent
    host = parent
    host_name = host.name
    host_ip_info = portgroup_data["hosts_info"].select {|h, _| h == host_name}
    host_ips << host_ip_info[host_name] if host_ip_info && host_ip_info[host_name]
  else
    host_ips = portgroup_data["hosts_info"].values if @port_group_info[port_group_name]
  end

  default_response[:host_ip_addresses] = host_ips || []

  return default_response unless portgroup_data["vlan_id"]

  return default_response unless portgroup_data["vlan_id"].is_a?(Integer)
  default_response[:vlan_id] = portgroup_data["vlan_id"]

  default_response
end

def collect_portgroup_attributes(network_obj, parent)
  pg_name = network_obj.name
  parent_name = parent.name
  if @std_port_group_info[pg_name] && @std_port_group_info[pg_name]["hosts_info"] &&
    @std_port_group_info[pg_name]["hosts_info"][parent_name]
    info = (@std_port_group_info[pg_name]["hosts_info"][parent_name] || []).find {|n| n[:name] == pg_name}
    return {} unless info
    vlan_id = info[:vlan_id]
    vswitch_name = info[:vswitch]
    return {} unless vlan_id.is_a?(Integer)

    {:vlan_id => vlan_id, :vswitch_name => vswitch_name}
  else
    return {}
  end
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
