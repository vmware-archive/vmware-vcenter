#!/opt/puppet/bin/ruby
require 'json'
require 'rbvmomi'
require 'trollop'

opts = Trollop::options do
  opt :server, 'vcenter address', :type => :string, :required => true
  opt :port, 'vcenter port', :default => 443
  opt :username, 'vcenter username', :type => :string, :required => true
  opt :password, 'vcenter password', :type => :string, :default => ENV['PASSWORD']
  opt :timeout, 'command timeout', :default => 240
  opt :community_string, 'dummy value for ASM, not used'
  opt :output, 'output facts to a file', :type => :string, :required => true
end
facts = {}

def collect_vcenter_facts(vim)
  inventory = collect_inventory(vim.serviceContent.rootFolder)
  name = vim.serviceContent.setting.setting.find{|x| x.key == 'VirtualCenter.InstanceName'}.value
  customization_specs = vim.serviceContent.customizationSpecManager.info.collect{|spec| spec.name}
  {
      :vcenter_name => name,
      :datacenter_count => @datacenter_count.to_s,
      :cluster_count => @cluster_count.to_s,
      :vm_count => @vm_count.to_s,
      :host_count => @host_count.to_s,
      :customization_specs => customization_specs.to_s,
      :inventory => inventory.to_json
  }
end

def collect_inventory(obj)
  hash = {:name => obj.name, :id => obj._ref, :type => obj.class, :attributes => {}, :children => []}
  case obj
    when RbVmomi::VIM::Folder
      obj.children.each { |resource| hash[:children] << collect_inventory(resource) }
    when RbVmomi::VIM::Datacenter
      @datacenter_count += 1
      vds_children = obj.networkFolder.children.find_all{|x| x.is_a?(RbVmomi::VIM::VmwareDistributedVirtualSwitch)}
      (obj.hostFolder.children + obj.datastoreFolder.children + vds_children).each { |resource| hash[:children] << collect_inventory(resource) }
    when RbVmomi::VIM::ClusterComputeResource
      @cluster_count += 1
      obj.host.each { |host| hash[:children] << collect_inventory(host) }
    when RbVmomi::VIM::ComputeResource
      #If ComputeResource but not ClusterComputeResource, it is a standalone host
      hash = collect_inventory(obj.host.first)
    when RbVmomi::VIM::HostSystem
      @host_count += 1
      hash[:attributes] = collect_host_attributes(obj)
      obj.vm.each{ |vm| hash[:children] << collect_inventory(vm)}
    when RbVmomi::VIM::VirtualMachine
      @vm_count += 1
      hash[:attributes] = collect_vm_attributes(obj)
    when RbVmomi::VIM::Datastore
      hash[:attributes] = collect_datastore_attributes(obj)
    when RbVmomi::VIM::VmwareDistributedVirtualSwitch
      obj.portgroup.each {|portgroup| hash[:children] << collect_inventory(portgroup)}
    when RbVmomi::VIM::DistributedVirtualPortgroup
      hash[:attributes] = collect_vds_portgroup_attributes(obj)
    else
  end
  hash
end

def collect_host_attributes(host)
  attributes = {}
  #For blades, there are 2 service tags.  1 for chassis, and one for the blade itself, and there doesn't seem to be anything distinguishing the 2
  service_tag_array = host.summary.hardware.otherIdentifyingInfo
                         .select{|x| x.identifierType.key=='ServiceTag'}
                         .collect{|x| x.identifierValue}
  attributes[:service_tags] = service_tag_array
  attributes
end

def collect_datastore_attributes(ds)
  attributes = {}
  #There seems to be some cases where a datastore has no hosts.  Seems like a case of bad data, but we don't want to break on this either way
  if ds.host.empty?
    return attributes
  end
  #Have to go through many steps in order to get the iscsi name and the iscsi group IP.  All the data doesn't seem to be in one place
  # so we have to get a piece of data from one place, and match it up to a different place to get all the data we want.
  host = ds.host.first.key
  host_config = get_host_config(host)
  mount_info = host_config.fileSystemVolume.mountInfo.find{|x| x.volume.name == ds.name}
  attributes[:volume_name] = mount_info.volume.name
  #TODO:  Handle HostNasVolume(or others), we don't handle currently
  unless mount_info.volume.is_a?(RbVmomi::VIM::HostVmfsVolume)
    return attributes
  end
  scsi_lun_disk_name = mount_info.volume.extent.first.diskName
  host_storage_device = host_config.storageDevice

  host_scsi_disk = host_storage_device.scsiLun.find{|lun| lun.canonicalName == scsi_lun_disk_name}
  if host_scsi_disk.nil?
    return attributes
  end
  attributes[:vendor] = host_scsi_disk.vendor
  scsi_lun_uuid = host_scsi_disk.uuid
  topology_targets = host_config.storageDevice.scsiTopology.adapter.collect do |adapter|
    adapter.target.find_all do |target|
      (target.transport.is_a?(RbVmomi::VIM::HostInternetScsiTargetTransport) ||
        target.transport.is_a?(RbVmomi::VIM::HostFibreChannelOverEthernetTargetTransport)) &&
        target.lun.find{|lun| lun.key.include?(scsi_lun_uuid)}
    end
  end.flatten
  if topology_targets.empty?
    return attributes
  end
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
  attributes
end

# Getting the host configuration manager can take 1-2 seconds.  Each datastore querying it can add a large amount of time to the inventory.
# This method helps by giving a cached version of the configuration manager to save a lot of the query time for the same host
def get_host_config(host)
  @host_configs ||= {}
  @host_configs[host.name] ||= host.config
end

def collect_vm_attributes(vm)
  {:template => vm.summary.config.template}
end

def collect_vds_portgroup_attributes(portgroup)
  attributes = {}
  vlan_id = portgroup.config.defaultPortConfig.vlan.vlanId
  attributes[:vlan_id] = vlan_id if vlan_id.is_a?(Integer)
  attributes
end

begin
  @datacenter_count = 0
  @cluster_count = 0
  @host_count = 0
  @vm_count = 0

  Timeout.timeout(opts[:timeout]) do
    vim = RbVmomi::VIM.connect(:host=>opts[:server], :password=>opts[:password], :user=> opts[:username], :port=>opts[:port], :insecure=>true)
    facts = collect_vcenter_facts(vim).to_json
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
