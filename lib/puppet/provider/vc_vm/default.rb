# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'yaml'
require File.join(provider_path, 'spbmapiutils')

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = 'Manages vCenter Virtual Machines.'

  def exists?
    initialize_property_flush

    return !!vm if resource[:ensure] == :absent

    vm && cdrom_iso == resource[:iso_file]
  end

   # return the mounted iso file name
  def cdrom_iso
    cdrom = vm.config.hardware.device.find { |hw| hw.class == RbVmomi::VIM::VirtualCdrom }

    return nil unless cdrom
    return nil unless cdrom.backing.class == RbVmomi::VIM::VirtualCdromIsoBackingInfo

    return cdrom.backing.fileName.split(" ").last
  end

  def flush
    if resource[:ensure] == :present
     self.power_state = :poweredOff unless (@property_flush.empty? || power_state == "poweredOff")

      if @property_flush[:network_vm_spec]
        vm.ReconfigVM_Task(
            :spec => @property_flush[:network_vm_spec]
        ).wait_for_completion
        # sleep, gives time for changed network configuration to get into effect
        sleep 10
      end

      configure_iso if @property_flush[:cd_iso_spec]
        self.power_state = :poweredOn unless (resource[:power_state] == :poweredOff || power_state == "poweredOn")
    end
  end

  def nfs_vm_datastore

    return nil unless vm

    vm_nfs_datatsore = vm.datastore.find { |ds|
      ds.info.respond_to?(:nas) && (ds.info.name == "_nfs_asm_#{vm.name}")
    }

    vm_nfs_datatsore
  end

  def srm
    @srm ||= vim.serviceInstance.content.storageResourceManager
  end

  def initialize_property_flush
    @property_flush = {}
  end

  def network_interfaces
    vm.config.hardware.device.collect do |x|
      {'portgroup'=>portgroup_name(x), 'nic_type'=>x.class.to_s.sub(/\AVirtual/, '').downcase} if x.class < RbVmomi::VIM::VirtualEthernetCard
    end.compact
  end

  def portgroup_name(network_device)
    return network_device.backing.deviceName if network_device.backing.respond_to?("deviceName")
    dvswitch_name = dvswitch_uuid(network_device.backing.port.switchUuid).name
    dvport_name = dvportgroup_portkey(dvswitch_name, network_device.backing.port.portgroupKey).name

    "%s (%s)" % [dvport_name, dvswitch_name]
  end


  # only return requested file name in resource parameter
  # actual state will not be set to property flush and not be accessible in_crete as this is called before setter
  def iso_file
    resource[:iso_file].first["name"] if resource[:iso_file]
  end

  def iso_file=(value)
    @property_flush[:cd_iso_spec] = true unless cdrom_iso == iso_file
  end


  def network_interfaces=(config)
    network_spec = network_adapter_spec
    Puppet.debug("Expected final network_spec #{network_spec.inspect}")
    if network_spec.size != 0
      vm_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
          :name => resource[:name],
          :deviceChange => network_spec
      )
      # adds to property_flush to configure at the end
      @property_flush[:network_vm_spec] = vm_spec
    end
  end


 def get_host_management_ip
   nic = find_vm_host.config.network.vnic.find { |nic| nic.device == "vmk0"}

   ASM::Util.get_preferred_ip(nic.spec.ip.ipAddress)
  end

  # Adds nfs_datastore on the host of the vm
  # checks for existing nfs_datastores if exist
  def add_nfs_datastore
    vm_host = find_vm_host
    hds = vm_host.configManager.datastoreSystem
    nfsdatastoreconfig = {:remoteHost => get_host_management_ip,
                          :remotePath => resource[:nfs]["remote_path"],
                          :localPath =>  "_nfs_asm_#{vm.name}",
                          :accessMode => "readOnly"
    }

    nfsds = get_nfs_datastore(hds)
    #checks if nfsdatastore already exists
    if nfsds
      Puppet.notice ("nfs is already mounted as %s" % nfsds.info.name )
    else
      nfsds = hds.CreateNasDatastore(:spec => VIM.HostNasVolumeSpec(nfsdatastoreconfig))
      Puppet.notice ("added nfs datastore %s and mounted" % nfsds.info.name )
    end

    nfsds
  end

  # finds host to add nfs_datastore and returns the host object
  def find_vm_host
    # datacenter.hostFolder.children is a tree with clusters having hosts in it.
    # needs to flatten nested array
    hosts = datacenter.hostFolder.children.map { |child| child.host }.flatten
    host = hosts.select { |host|
      host.vm.find { |hvm|
        hvm == vm
      }
    }.first

    host
  end

  # Selects nfs datastore on the host
  def get_nfs_datastore(host_ds)
    host_ds.datastore.find { |ds|
      ds.info.respond_to?(:nas) &&
          ds.info.name == "_nfs_asm_#{vm.name}" &&
          ds.info.nas.remoteHost == ASM::Util.get_preferred_ip(find_vm_host.name)
    }
  end

  # removes nfsdatastore from hots while vm_teardown
  # make sure existing iso should be detached from cd?dvd before removing nfs_datastore
  def remove_nfs_datastore
    vm_host = find_vm_host
    nfsdatastore = get_nfs_datastore(vm_host)

    if nfsdatastore
      Puppet.notice "removing nfs datastore"
      vm_host.configManager.datastoreSystem.RemoveDatastore(:datastore => nfsdatastore)
    end
  end

  def network_adapter_spec
    network_spec = []
    new_networks = resource[:network_interfaces]
    new_network_names = new_networks.collect { |n| n["portgroup"] }
    adapters = vm.config.hardware.device.find_all do |x|
      x if x.class < RbVmomi::VIM::VirtualEthernetCard
    end
    index = 0
    adapters_to_remove = []

    # We loop through and make a list of network adapters to be removed by
    # comparing the requested networks to the networks on the existing adapters
    adapters.each do |adapter|
      if adapter.backing.is_a?(RbVmomi::VIM::VirtualEthernetCardDistributedVirtualPortBackingInfo)
        network_label = portgroup_name(adapter)
      else
        network_label = adapter.backing.deviceName
      end
      if new_network_names[index] == network_label
        index += 1
      else
        adapters_to_remove << adapter
      end
    end

    # Generate specs to remove network adapters
    adapters_to_remove.each do |extra_adapter|
      network_spec << RbVmomi::VIM.VirtualDeviceConfigSpec(
          :device => extra_adapter,
          :operation =>  RbVmomi::VIM.VirtualDeviceConfigSpecOperation("remove")
      )
    end

    # Add specs to add network adapters
    networks_to_add = new_networks[index..-1]
    network_spec.concat(network_specs(networks_to_add)) if networks_to_add
    network_spec
  end

  def create
    unless vm
      if resource[:ovf_url]
	Puppet.debug "Starting ovf deploy from url %s" % resource[:ovf_url].to_s      
        deploy_ovf 	
      elsif resource[:template]
        clone_vm
      else
        create_vm
      end

      raise(Puppet::Error, "Unable to create VM: '#{resource[:name]}'") unless vm
    end

    # PCI passthrough can be enabled after VM is created because vm_host is required for this process
    configure_pci_passthru

   # configures cdrom in flush method
    @property_flush[:cd_iso_spec] = true unless cdrom_iso == iso_file
  end

  # Configure pci passthrough device if one is available
  # PCI passthrough can be enabled after VM is created because vm_host is required for this process
  def configure_pci_passthru
    if available_pci_passthru_device
      Puppet.debug("Adding pci passthrough devices to: %s" % resource[:name])
      spec = RbVmomi::VIM.VirtualMachineConfigSpec(:deviceChange => [pci_passthru_device_spec], :memoryAllocation => {:reservation => resource[:memory_mb]})
      task = vm.ReconfigVM_Task(:spec => spec)
      task.wait_for_completion
      raise("Failed vm configuration task for %s with error %s" % [vm.name, task.info[:error][:localizedMessage]]) if task.info[:state] == "error"
    else
      Puppet.debug("Skipping PCI pass through configuration for vm: as no devices available." % resource[:name])
    end
  end

  # mount iso to cd drive or detach iso based on iso_file resource
  # adds or removes nf data_store for mounting/unmounting  iso
  def configure_iso
    cdrom = vm.config.hardware.device.find { |hw| hw.class == RbVmomi::VIM::VirtualCdrom }

    if iso_file && iso_file != :undef
      nfs_ds = add_nfs_datastore
      # attach iso from cd/DVD drive
      vm.ReconfigVM_Task(:spec => vm_reconfig_spec(nfs_ds, cdrom)).wait_for_completion
    else
      # removes only if iso is attached
      if cdrom_iso
        # detach iso from cd/DVD drive
        vm.ReconfigVM_Task(:spec => vm_reconfig_spec(nil, cdrom)).wait_for_completion
        Puppet.debug "detached Iso from cdrom"
        remove_nfs_datastore
        Puppet.debug("removed Nfs datastore from %s" % vm.name)
      end
    end
  end

  def vm_reconfig_spec(datastore,  cd_obj = nil)
    RbVmomi::VIM.VirtualMachineConfigSpec(:deviceChange => [*cdrom_spec(datastore,cd_obj)])
  end

  def destroy
    if power_state == 'poweredOn'
      Puppet.notice "Powering off VM #{resource[:name]} prior to removal."
      vm.PowerOffVM_Task.wait_for_completion
    else
      Puppet.debug "Virtual machine state: #{power_state}"
    end

    if cdrom_iso
      cdrom = vm.config.hardware.device.find { |hw| hw.class == RbVmomi::VIM::VirtualCdrom }
      # detach iso from cd/DVD drive
      vm.ReconfigVM_Task(:spec => vm_reconfig_spec(nil, cdrom)).wait_for_completion
      Puppet.debug "detached Iso from cdrom"
      remove_nfs_datastore
      Puppet.debug("removed Nfs datastore from %s" % vm.name)
    end

    find_vm_host.configManager.datastoreSystem.RemoveDatastore(:datastore => nfs_vm_datastore) if nfs_vm_datastore
    vm.Destroy_Task.wait_for_completion
  end

  def customization_spec(vm_adaptercount)
    host_name = RbVmomi::VIM.CustomizationFixedName(:name => resource[:name])

    case resource[:guest_type].to_s
    when 'windows'
      identity = windows_sysprep(host_name)
    when 'linux'
      identity = RbVmomi::VIM.CustomizationLinuxPrep(
        :domain => resource[:domain],
        :hostName => host_name,
        :timeZone => resource[:timezone]
      )
    end

    #Creating NIC specification
    nic_setting = get_nics(vm_adaptercount)

    RbVmomi::VIM.CustomizationSpec(
      :identity => identity,
      :globalIPSettings => RbVmomi::VIM.CustomizationGlobalIPSettings,
      :nicSettingMap => nic_setting
    )
  end

  def windows_sysprep(computer_name)
    raise(Puppet::Error, 'Windows Product ID cannot be blank.') unless resource[:product_id]
    domain_admin = resource[:domain_admin]
    domain_admin_pass = resource[:domain_password]
    domain = resource[:domain]

    if domain_admin && domain_admin_pass && domain

      password = RbVmomi::VIM.CustomizationPassword(
        :plainText => true,
        :value     => domain_admin_pass
      )
      identification = RbVmomi::VIM.CustomizationIdentification(
        :domainAdmin         => domain_admin,
        :domainAdminPassword => password,
        :joinDomain          => domain
      )
    else
      identification = RbVmomi::VIM.CustomizationIdentification
    end

    admin_password = resource[:admin_password]

    timezone = resource[:timezone]
    autologon = resource[:autologon]
    autologon_count = resource[:autologon_count]

    if admin_password
      password =  RbVmomi::VIM.CustomizationPassword(
        :plainText => true,
        :value     => admin_password
      )
      gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(
        :autoLogon      => autologon,
        :autoLogonCount => autologon_count,
        :password       => password,
        :timeZone       => timezone
      )
    else
      gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(
        :autoLogon      => autologon,
        :autoLogonCount => autologon_count,
        :timeZone       => timezone
      )
    end

    user_data = RbVmomi::VIM.CustomizationUserData(
      :computerName => computer_name,
      :fullName     => resource[:full_name],
      :orgName      => resource[:org_name],
      :productId    => resource[:product_id]
    )

    license_mode = resource[:license_mode]
    mode = RbVmomi::VIM.CustomizationLicenseDataMode(license_mode);

    if license_mode.to_s == 'perServer'
      license = RbVmomi::VIM.CustomizationLicenseFilePrintData(
        :autoMode => mode,
        :autoUsers => resource[:license_users]
      )
    else
      license = RbVmomi::VIM.CustomizationLicenseFilePrintData(
        :autoMode => mode
      )
    end

    RbVmomi::VIM.CustomizationSysprep(
      :guiUnattended => gui_unattended,
      :identification => identification,
      :licenseFilePrintData => license,
      :userData => user_data
    )
  end

  # Get Nic Specification
  def get_nics(vm_adaptercount)
    cust_adapter_mapping_arr = nil
    customization_spec = nil
    nic_count = 0
    nic_spechash = resource[:nicspec]
    if nic_spechash
      nic_val = nic_spechash["nic"]

      if nic_val
        nic_count = nic_val.length
        if nic_count > 0
          count = 0
          nic_val.each_index {
            |index, val|

            if count > vm_adaptercount-1
              break
            end
            iparray = nic_val[index]
            cust_ip_settings = gvm_ipspec(iparray)

            cust_adapter_mapping = RbVmomi::VIM.CustomizationAdapterMapping(:adapter => cust_ip_settings )

            if count > 0
              cust_adapter_mapping_arr.push (cust_adapter_mapping)
            else
              cust_adapter_mapping_arr = Array [cust_adapter_mapping]
            end

            count = count + 1
          }
        end
      end
    end

    # Update the remaining adapters of with defaults settings.
    remaining_adapterscount = vm_adaptercount - nic_count

    if remaining_adapterscount > 0
      remaining_customization_fixed_ip = RbVmomi::VIM.CustomizationDhcpIpGenerator
      remaining_cust_ip_settings = RbVmomi::VIM.CustomizationIPSettings(:ip => remaining_customization_fixed_ip )
      remianing_cust_adapter_mapping = RbVmomi::VIM.CustomizationAdapterMapping(:adapter => remaining_cust_ip_settings )
      cust_adapter_mapping_arr.push (remianing_cust_adapter_mapping)
    end
    return cust_adapter_mapping_arr
  end

  # Guest VM IP spec
  def gvm_ipspec(iparray)

    ip_address = nil
    subnet = nil
    dnsserver = nil
    gateway = nil

    dnsserver_arr = []
    gateway_arr = []

    iparray.each_pair {
      |key, value|

      ip_address = value if key.eql?('ip')
      subnet = value if key.eql?('subnet')

      if key == "dnsserver"
        dnsserver = value
        dnsserver_arr.push (dnsserver)
      end

      if key == "gateway"
        gateway = value
        gateway_arr.push (gateway)
      end
    }

    if ip_address
      ip = RbVmomi::VIM.CustomizationFixedIp(:ipAddress => ip_address)
    else
      ip = RbVmomi::VIM.CustomizationDhcpIpGenerator
    end

    cust_ip_settings = RbVmomi::VIM.CustomizationIPSettings(
      :ip => ip,
      :subnetMask => subnet,
      :dnsServerList => dnsserver_arr,
      :gateway => gateway_arr,
      :dnsDomain => resource[:domain]
    )
  end

  # Method to create VM relocate spec
  def relocate_spec
    if resource[:cluster]
      spec = RbVmomi::VIM.VirtualMachineRelocateSpec(
        :pool => cluster.resourcePool,
        :transform => transform
      )
    elsif resource[:host]
      spec = RbVmomi::VIM.VirtualMachineRelocateSpec(
        :host => host,
        :pool => host.parent.resourcePool,
        :transform => transform
      )
    else
      raise(Puppet::Error, 'Must provider cluster or host for VM deployment')
    end

    datastore = resource[:datastore]
    unless datastore
      ds = get_cluster_datastore
      raise(Puppet::Error, "Unable to find the target datastore '#{datastore}'") unless ds
      spec.datastore = datastore_object(ds)
    else
      spec.datastore = datastore_object("[#{datastore}]")
    end

    spec
  end

  def cluster(name=resource[:cluster])
    cluster = datacenter.find_compute_resource(name)
    raise Puppet::Error, "Unable to find the cluster '#{name}'" unless cluster
    cluster
  end

  def transform
    # TODO: This appears to be deprecated
    if resource[:disk_format].to_s == 'thin'
      diskformat = 'sparse'
    else
      diskformat = 'flat'
    end

    RbVmomi::VIM.VirtualMachineRelocateTransformation(diskformat)
  end


  def power_state
    Puppet.debug 'Retrieving the power state of the virtual machine.'
    @power_state = vm.runtime.powerState
  rescue Exception => e
    fail "Unable to retrive the power state of the virtual machine because the following exception occurred: -\n #{e.message}"
  end

  # Set the power state.
  def power_state=(value)
    Puppet.debug 'Setting the power state of the virtual machine.'

    case value
    when :poweredOff
      if (vm.guest.toolsStatus == 'toolsNotInstalled') or
        (vm.guest.toolsStatus == 'toolsNotRunning') or
        (resource[:graceful_shutdown] == :false)
        vm.PowerOffVM_Task.wait_for_completion unless power_state == 'poweredOff'
      else
        vm.ShutdownGuest
        # Since vm.ShutdownGuest doesn't return a task we need to poll the VM powerstate before returning.
        attempt = 5  # let's check 5 times (1 min 15 seconds) before we forcibly poweroff the VM.
        while power_state != 'poweredOff' and attempt > 0
          sleep 15
          attempt -= 1
        end
        vm.PowerOffVM_Task.wait_for_completion unless power_state == 'poweredOff'
      end
    when :poweredOn
      vm.PowerOnVM_Task.wait_for_completion
    when :suspended
      if @power_state == 'poweredOn'
        vm.SuspendVM_Task.wait_for_completion
      else
        raise(Puppet::Error, 'Unable to suspend the virtual machine unless in powered on state.')
      end
    when :reset
      if @power_state !~ /poweredOff|suspended/i
        vm.ResetVM_Task.wait_for_completion
      else
        raise(Puppet::Error, "Unable to reset the virtual machine because the system is in #{@power_state} state.")
      end
    end
  end

  def host
    @host ||= vim.searchIndex.FindByIp(:datacenter => datacenter , :ip => get_host_management_ip, :vmSearch => false) or raise(Puppet::Error, "Unable to find the host '#{resource[:host]}'")
  end

   # Whether the datastore is an internal NFS datastore
   #
   # An NFS datastore is used for mounting a virtual ISO. This returns true if
   # the name appears to be one of those.
   #
   # @param [String] the datastore name
   # @return [Boolean] if it is an internal NFS datastore
  def is_internal_nfs_datastore?(name)
    name.start_with?("_nfs_asm")
  end

   # Whether the datastore name refers to a local datastore
   #
   # @param [String] the datastore name
   # @return [Boolean] if it is a local datastore
  def is_local_datastore?(name)
    !!name.match(/local-storage-\d+|DAS\d+/)
  end

   # Whether the datastore can be used for deploying VMs
   #
   # Returns true if the datastore is appropriate for deploying a VM to.
   #
   # @param [<Hash>] The datastore info. See the #get_cluster_datastore example response for the Hash format.
   # @return [Boolean] true if the datastore is usable
  def usable_datastore?(datastore)
    return false if is_internal_nfs_datastore?(datastore["name"])

    return false unless datastore["summary.accessible"]

    return true unless is_local_datastore?(datastore["name"])

    resource[:skip_local_datastore] == :false
  end

   # Return an ordered list of datastore info hashes
   #
   # Returns an ordered list of datastore summary info hashes. The non-local
   # datastores will be returned first with those that have the most available
   # space returned first. Local datastores will be returned after the
   # non-local datastores also in order of those with the most available space
   # first.
   #
   # @param [Array<RbVmomi::VIM::ObjectContent>]
   # @return [Array<Hash>] priority ordered list of datastore info. See the
   #                       #get_cluster_datastore example response for the Hash format.
  def prioritized_datastores(datastores)
    datastore_info = datastores.map do |d|
      size = d["summary.capacity"]
      free = d["summary.freeSpace"]
      used = size - free
      is_local = is_local_datastore?(d["name"])

      info = {
          "name" => d["name"], "size" => size, "free" => free, "used" => used,
          "info" => d["info"], "summary" => d["summary"], "is_local" => is_local
      }

      info if usable_datastore?(d)
    end

    datastore_info += get_cluster_storage_pods
    datastore_info.compact!

    #Sort order: Pod -> Remote Datastore -> Local Datastore (each sorted by free size)
    datastore_info.sort_by! {|h| [h["pod"] ? 0 : 1, h["is_local"] ? 1 : 0, -h["free"]]}
  end

   # Return the cluster datastore to deploy the VM on
   #
   # If `resource[:datastore]` is specified, that is returned if it has enough
   # available space.
   #
   # Otherwise the non-local datastore with the most available space will be
   # returned. If there are no non-local datastores the local datastore with
   # the most available space will be returned.
   #
   # @example response
   #   {
   #      "name"=>"gs4esx2-local-storage-1",
   #      "size"=>591363309568,
   #      "free"=>564766179328,
   #      "used"=>26597130240,
   #      "info"=>#<RbVmomi::VIM::VmfsDatastoreInfo>,
   #      "summary"=>#<RbVmomi::VIM::DatastoreSummary>,
   #      "is_local"=>#<MatchData "local-storage-1">
   #   }
   #
   # @return [Hash] Hash of datastore info as shown in example
   # @raise [StandardException] if no datastore meeting space requirements is found
  def get_cluster_datastore
    requested_datastore = (resource[:datastore] || '')

    # Disk size is in KB and the information coming back from 
    # API is in Bytes
    if resource[:virtual_disks]
      requested_size = 0
      # virtual_disks size is originally in gb
      resource[:virtual_disks].each {|disk| requested_size += disk["size"].to_i * 1024 * 1024}
      requested_size *= 1024
    else
      requested_size = resource[:disk_size].to_i * 1024
    end

    paths = %w(name info.url info summary summary.accessible summary.capacity summary.freeSpace)
    propSet = [{:type => 'Datastore', :pathSet => paths}]
    filterSpec = {:objectSet => cluster.datastore.map {|ds| {:obj => ds}}, :propSet => propSet}
    data = vim.propertyCollector.RetrieveProperties(:specSet => [filterSpec])

    datastore_info = prioritized_datastores(data)
    Puppet.debug("Requested size: #{requested_size}")

    if !requested_datastore.empty?
      info = datastore_info.find {|d| d['name'] == requested_datastore}

      raise("Datastore #{requested_datastore} not found") unless info

      raise("In-sufficient space in datastore #{requested_datastore}") if info['free'] < requested_size

      info
    else
      datastore_selected = datastore_info.find {|d| d['free'] >= requested_size}

      raise("No datastore found with sufficient free space") unless datastore_selected
      Puppet.debug("Selected datastore: #{datastore_selected['name']}")

      datastore_selected
    end
  end

  def get_cluster_storage_pods
    paths = %w(name summary.capacity summary.freeSpace)
    property_set = [{:type => "StoragePod", :pathSet => paths}]
    filter_spec = {:objectSet => datacenter.datastoreFolder.childEntity.map {|ds| {:obj => ds} }, :propSet => property_set}
    data = vim.propertyCollector.RetrieveProperties(:specSet => [filter_spec])
    datastore_info = data.map do |d|
      size = d["summary.capacity"]
      free = d["summary.freeSpace"]
      used = size - free
      name = d["name"]
      info = {
        "name" => name, "size" => size, "free" => free, "used" => used, "pod" => true, "obj" => d.obj
      }
      info
    end.compact
    Puppet.debug("Found Storage Pods: #{datastore_info}")
    datastore_info
  end

  def create_vm
    cluster_name = resource[:cluster]
    host_name = resource[:host]
    ds_path = nil

    if cluster_name
      resource_pool = cluster.resourcePool
      datastore = get_cluster_datastore
      ds_path = datastore["name"]
      if datastore["pod"]
        create_pod_vm(storage_placement_spec(datastore, resource_pool))
        return
      end
    elsif host_name
      resource_pool = host.parent.resourcePool
      ds = host.datastore.first
    else
      raise(Puppet::Error, 'Must provider cluster or host for VM deployment')
    end

    ds_path = "[#{ds.name}]" if ds_path.nil?
    raise(Puppet::Error, 'No datastores exist for the host') if ds_path.nil?

    datacenter.vmFolder.CreateVM_Task(:config => vm_config_spec("[#{ds_path}]"), :pool => resource_pool).wait_for_completion

    # power_state= did not work.
    self.send(:power_state=, resource[:power_state].to_sym)
  end

  def create_pod_vm (spec)
    rec = srm.RecommendDatastores(:storageSpec => spec)
    rec_key = rec.recommendations[0].key
    srm.ApplyStorageDrsRecommendation_Task(:key => [rec_key]).wait_for_completion
    self.send(:power_state=, resource[:power_state].to_sym)
  end

  def vm_config_spec(path="")
    vm_devices = []
    vm_devices.push(scsi_controller_spec)
    vm_devices.push(*disk_specs(path))
    vm_devices.push(*network_specs)
    vm_devices.push(*cdrom_spec)

    config = {
        :name => resource[:name],
        :memoryMB => resource[:memory_mb],
        :numCPUs => resource[:num_cpus],
        :numCoresPerSocket => resource[:num_cpus],
        :guestId => resource[:guestid],
        :files => { :vmPathName => path },
        :memoryHotAddEnabled => resource[:memory_hot_add_enabled],
        :cpuHotAddEnabled => resource[:cpu_hot_add_enabled],
        :deviceChange => vm_devices
    }
    if vsan_data_store?(path) && resource[:vm_storage_policy]
      config[:vmProfile] = [VIM::VirtualMachineDefinedProfileSpec(
          :profileId => profile(resource[:vm_storage_policy]).profileId.uniqueId
      )]
    end
    Puppet.debug("VM Create config: #{config.inspect}")
    RbVmomi::VIM.VirtualMachineConfigSpec(config)
  end

  def available_pci_passthru_device
    # first check if host has pci passthrough device available
    pci_passthru_dev = find_vm_host.config.pciPassthruInfo.find { |pci| pci.passthruActive == true }
    if pci_passthru_dev
      # check that no other VM is using the passthrough device
      find_vm_host.vm.each do |other_vm|
        if other_vm.config.hardware.device.grep(RbVmomi::VIM::VirtualPCIPassthrough).find { |other_vm_device| other_vm_device.backing.id == pci_passthru_dev.id }
          return nil
        end
      end
      pci_passthru_dev
    else
      nil
    end
  end

  def pci_passthru_device_spec
    pci_passthru_device = available_pci_passthru_device
    Puppet.debug("Found an active PCI passthrough device with id, #{pci_passthru_device.id}")

    pci_device = find_vm_host.hardware.pciDevice.find { |pci_dev| pci_dev.id ==  pci_passthru_device.id }
    pci_id = pci_device.id
    pci_device_id = pci_device.deviceId.to_s(16)
    vendor_id = pci_device.vendorId
    host_uuid = find_vm_host.esxcli.system.uuid.get

    Puppet.debug("Configuring PCI passthrough on VM with device, #{pci_device}: id=#{pci_id}, device_id=#{pci_device_id}, vendor_id=#{vendor_id}, host_uuid=#{host_uuid}")
    backing = RbVmomi::VIM.VirtualPCIPassthroughDeviceBackingInfo(
        :id => pci_id,
        :deviceId => pci_device_id,
        :vendorId => vendor_id,
        :systemId => host_uuid,
        :deviceName => ""
    )

    pciDevice = RbVmomi::VIM.send(:VirtualPCIPassthrough, :backing => backing, :key => 0)

    RbVmomi::VIM.VirtualDeviceConfigSpec(
        :device => pciDevice,
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
    )
  end

  def profile(profile_name)
    @profile ||= exiting_profiles.find {|x| x.name == profile_name}
  end

  def pbm
    @pbm ||= vim.pbm
  end

  def pbm_manager
    @pbm_manager ||= pbm.serviceContent.profileManager
  end

  def exiting_profiles
    profiles = []
    profileIds = pbm_manager.PbmQueryProfile(
        :resourceType => {:resourceType => "STORAGE"},
        :profileCategory => "REQUIREMENT"
    )

    if profileIds.length > 0
      profiles = pbm_manager.PbmRetrieveContent(:profileIds => profileIds)
    end

    profiles
  end

  def vsan_data_store?(datastore)
    datastore =~ /vsanDatastore/
  end

  def storage_placement_spec(datastore, resource_pool)
    RbVmomi::VIM.StoragePlacementSpec({
      :type => "create",
      :podSelectionSpec => storage_drs_pod_selection_spec(datastore),
      :configSpec => vm_config_spec,
      :resourcePool => resource_pool,
      :folder => datacenter.vmFolder
                                       })
  end

  def storage_drs_pod_selection_spec(datastore)
  RbVmomi::VIM.StorageDrsPodSelectionSpec({
    :initialVmConfig => [initial_pod_vm_config(datastore)],
    :storagePod => datastore["obj"],
                                          })
  end

  def initial_pod_vm_config(datastore)
    RbVmomi::VIM.VmPodConfigForPlacement({
      :storagePod => datastore["obj"]
                                         })
  end

  def pod_disk_locator
    RbVmomi::VIM.PodDiskLocator({
      :diskId          => -48,
      :diskBackingInfo => disk_backing,
                                })
  end

  def controller_map
    {
      'VMware Paravirtual' => :ParaVirtualSCSIController,
      'LSI Logic Parallel' => :VirtualLsiLogicController,
      'LSI Logic SAS' => :VirtualLsiLogicSASController,
      'BusLogic Parallel' => :VirtualBusLogicController,
    }
  end

  def scsi_controller_spec
    type = resource[:scsi_controller_type].to_s

    controller = RbVmomi::VIM.send(
      controller_map[type],
      :key => 0,
      :device => [0],
      :busNumber => 0,
      :sharedBus => RbVmomi::VIM.VirtualSCSISharing('noSharing')
    )

    RbVmomi::VIM.VirtualDeviceConfigSpec(
      :device => controller,
      :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
    )
  end

  def disk_backing(file_name="")
    thin = (resource[:disk_format].to_s == 'thin')

    RbVmomi::VIM.VirtualDiskFlatVer2BackingInfo(
      :diskMode => 'persistent',
      :fileName => file_name,
      :thinProvisioned => thin
    )
  end

  # return iso_bakinginfo object only if iso_file name is present in resource.
  def cd_drive_backing_info(datastore=nil)
    if datastore && iso_file
      return RbVmomi::VIM.VirtualCdromIsoBackingInfo(:datastore => datastore, :fileName => "[#{datastore.info.name}]/#{iso_file}")
    else
      return RbVmomi::VIM.VirtualCdromRemotePassthroughBackingInfo(:deviceName => "CDROM", :exclusive => false, :useAutoDetect => false)
    end
  end

  # Spec for creating virtualCdRom and attach iso if required
  # it creates CDROM with iso image on the nfs_datastore each time creating new_vm
  #
  # @note iso needs to be detached before removing nfs_datastore
  # @param datastore [RbVmomi::VIM.Datastore]
  # @param cdrom [RbVmomi::VIM.VirtualCdrom] object of the existing cd_drive for edit operation
  #
  # @return [RbVmomi::VIM.VirtualDeviceConfigSpec]
  def cdrom_spec(datastore=nil, cdrom=nil)
    disk = RbVmomi::VIM.VirtualCdrom(
        :backing => cd_drive_backing_info(datastore),
        :connectable => virtualcd_connect_info(datastore),
        :controllerKey => cdrom ? cdrom.controllerKey : 201, #IDE Controllers start at 200
        :key => cdrom ? cdrom.key : 999,
        :unitNumber => cdrom ? cdrom.unitNumber : 0
    )

     # edit cd_drive if vm is created and cd drive already exists else add cd_drive
   if cdrom
     config = {
         :device => disk,
         :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation("edit")
     }
   else
     config = {
         :device => disk,
         :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation("add")
     }
   end

    RbVmomi::VIM.VirtualDeviceConfigSpec(config)
  end

  def virtualcd_connect_info(datastore)
    RbVmomi::VIM.VirtualDeviceConnectInfo(
        :allowGuestControl => true,
        :connected => datastore && iso_file ? true : false,
        :startConnected => datastore && iso_file ? true : false
    )
  end

  #Returns an array of all the disk specs
  def disk_specs(path)
    specs = []
    unit = 0
    if resource[:virtual_disks]
      resource[:virtual_disks].each do |vd|
        size = vd["size"].to_i * 1024 * 1024
        specs << disk_spec(path, size, unit)
        unit += 1
      end
    else
      specs << disk_spec(path, resource[:disk_size], unit)
    end

    specs
  end

  #  create virtual device config spec for disk
  def disk_spec(file_name, size, unit)
    disk = RbVmomi::VIM.VirtualDisk(
      :backing => disk_backing(file_name),
      :controllerKey => 0,
      :key => 0,
      :unitNumber => unit,
      :capacityInKB => size
    )

    config = {
        :device => disk,
        :fileOperation => RbVmomi::VIM.VirtualDeviceConfigSpecFileOperation('create'),
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
    }

    if vsan_data_store?(file_name) && resource[:vm_storage_policy]
      config[:profile] = [VIM::VirtualMachineDefinedProfileSpec(
          :profileId => profile(resource[:vm_storage_policy]).profileId.uniqueId
      )]
    end

    RbVmomi::VIM.VirtualDeviceConfigSpec(config)
  end

  # get network configuration
  def network_specs(interfaces=resource[:network_interfaces], action='add')
    interfaces.each_with_index.collect do |nic, index|
      portgroup = nic['portgroup']
      if portgroup.match(/^(\b.*?)\ \((.*?)\)$/)
        backing = RbVmomi::VIM.VirtualEthernetCardDistributedVirtualPortBackingInfo
        port = RbVmomi::VIM.DistributedVirtualSwitchPortConnection
        port.portgroupKey = dvportgroup($2,$1).key
        port.switchUuid = dvswitch($2).uuid
        backing.port = port
      else
        backing = RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(:deviceName => portgroup)
      end
      nic =  RbVmomi::VIM.send(
        "Virtual#{PuppetX::VMware::Util.camelize(nic['nic_type'])}".to_sym,
        {
          :key => index,
          :backing => backing,
          :deviceInfo => {
            :label => "Network Adapter",
            :summary => portgroup
          }
        }
      )
      RbVmomi::VIM.VirtualDeviceConfigSpec(
        :device => nic,
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation(action)
      )
    end
  end

  # Returns the host associated with the provided datastore
   # and compute resource which is the cluster.
  def host_from_datastore(datastore, cluster)
    pc = vim.serviceContent.propertyCollector
    hosts = cluster.host
    hosts_props = pc.collectMultiple(
        hosts,
        'datastore', 'runtime.connectionState',
        'runtime.inMaintenanceMode', 'name'
    )
    host = hosts.shuffle.find do |x|
      host_props = hosts_props[x]
      is_connected = host_props['runtime.connectionState'] == 'connected'
      is_ds_accessible = host_props['datastore'].member?(datastore)
      is_connected && is_ds_accessible && !host_props['runtime.inMaintenanceMode']
    end
    raise("No host in the cluster available to upload OVF to") unless host

    host
  end

  # Returns the portgroup name and VDS name as a list
  # The first element is the portgroup name and the second is the VDS name
  def network_names(net)
    net["portgroup"].match(/^(\b.*?)\ \((.*?)\)$/)
    [$1,$2]
  end

  # Returns a hash of the network mappings from VM Networks in the
  # provided OVF file to the networks that exist on a host.  It takes
  # the desired network names as input, and finds the associated network
  # object on the host to include in the mapping.
  def network_mappings(ovf_url, cluster)
    network_mappings = {}
    # Query OVF to find any networks which need to be mapped
    begin
      ovf = open(ovf_url, 'r'){|io| Nokogiri::XML(io.read)}
    rescue
      Puppet.debug("Failed to open ovf: %s for reason: %s" % [ovf_url.to_s, $!.to_s])
      raise
    end

    raise("Unable to obtain ovf from: %s" % ovf_url) unless ovf

    ovf.remove_namespaces!
    networks = ovf.xpath('//NetworkSection/Network').map{|x| x['name']}
    return network_mappings unless networks

    # If list of networks were passed as input then map them to the VM Networks in the
    # OVF.  If fewer networks are passed in that what are available on the OVF the last
    # input network will be repeated on all available VMNetworks
    if resource[:network_interfaces]
      this_net = nil
      resource[:network_interfaces].each_with_index do |net,index|
        portgroup_name = network_names(net).first
        this_net = cluster.network.find{|x| x.name == portgroup_name}
        raise("Input network name: %s is not found in cluster" % portgroup_name) unless this_net
        Puppet.debug("Mapping network %s to %s" % [networks[index], this_net.name])
        network_mappings[networks[index]] = this_net
      end
      # If input network list was smaller than number of VM Networks in the OVF
      # Fill in remaining OVF networks with last available input network
      if resource[:network_interfaces].size < networks.size
        networks[resource[:network_interfaces].size..-1].each do |net|
          network_mappings[net] = this_net
          Puppet.debug("Mapping network %s to %s" % [net, this_net.name])
        end
      end
    else
      network = cluster.network[0]
      network_mappings = Hash[networks.map{|x| [x, network]}]
    end
    
    network_mappings = adjust_networks_flex_svm(network_mappings, networks) if resource[:network_interfaces]
    
    network_mappings     
  end

  # Fixes issue with VMware Network mapping not being applied in logical order
  def adjust_networks_flex_svm(network_mappings, networks)
    mgmt = network_mappings[networks[0]]
    d1 = network_mappings[networks[1]]
    d2 = network_mappings[networks[2]]
    network_mappings[networks[0]] = d1
    network_mappings[networks[1]] = d2
    network_mappings[networks[2]] = mgmt
    network_mappings
  end

  # Use reconfigure VM task to set memory and CPU on VM
  # This will return error if VM is not in the powered off state
  # Input memory is in MB
  def vm_memory_cpu_scsi_for_svm(vm, memory_in_mb, num_cpu)
    Puppet.debug("Setting VM memory: %s MB, %s CPUs, and reserving guest memory" % [memory_in_mb.to_s, num_cpu])
    scsis = vm.config.hardware.device.find_all { |dev| dev.is_a?(RbVmomi::VIM::ParaVirtualSCSIController)}
    device_change_spec = []
    if scsis.size > 1
      scsis[1..-1].each do |scsi|
        device_change_spec << RbVmomi::VIM.VirtualDeviceConfigSpec(:device => scsi, 
                                                    :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation("remove"))
      end
      Puppet.debug("Removing %s extra ParaVirtualSCSIControllers from VM %s" % [device_change_spec.size.to_s, resource[:name]])
    end
    config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
            :memoryMB => memory_in_mb,
            :numCPUs => num_cpu,
            :numCoresPerSocket => num_cpu,
            :memoryReservationLockedToMax => true,
            :deviceChange => device_change_spec
    )
    task = vm.ReconfigVM_Task(:spec => config_spec)
    task.wait_for_completion
    raise("Failed vm configuration task for %s with error %s" % [vm.name, task.info[:error][:localizedMessage]]) if task.info[:state] == "error"
  end

  # This method create a VMware Virtual Machine instance based on an OVF provided
  # via a URL location.
  def deploy_ovf
    vm_name = resource[:name]
    ovf_url = resource[:ovf_url]
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    datastore = dc.find_datastore(resource[:datastore])
    cluster = dc.find_compute_resource(resource[:cluster])
    raise("Could not find datacenter, datastore, or cluster") unless dc && datastore && cluster

    Puppet.debug("Deploying vm %s, to datacenter: %s and cluster: %s and datastore: %s" % [vm_name.to_s, dc.name, cluster.name, datastore.name])

    # Use root vm folder for deployment if no folder passed in as input
    root_vm_folder = dc.vmFolder
    vm_folder = root_vm_folder
    if resource[:vm_folder_path]
      vm_folder = root_vm_folder.traverse(resource[:vm_folder_path], VIM::Folder)
      raise("Could not find VM folder: %s" % resource[:vm_folder_path])
    end
    Puppet.debug("Using vm folder: %s" % vm_folder.name)

    # Find host associated with the target datastore for this VM
    host = host_from_datastore(datastore, cluster)
    Puppet.debug("Deploying vm: %s to host: %s" % [vm_name.to_s, host.name.to_s])
    vm = nil
    begin
      vm = vim.serviceContent.ovfManager.deployOVF(
          uri: ovf_url,
          vmName: vm_name,
          vmFolder: vm_folder,
          host: host,
          resourcePool: cluster.resourcePool,
          datastore: datastore,
          networkMappings: network_mappings(ovf_url, cluster),
          propertyMappings: {})
    rescue RbVmomi::Fault => fault
      Puppet.debug("Failure during OVF deployment for vm: %s with error %s: %s" % [vm_name.to_s, $!.to_s, $!.class])
      raise
    end

    if resource[:memory_mb] || resource[:num_cpus]
      vm_memory_cpu_scsi_for_svm(vm, resource[:memory_mb], resource[:num_cpus]) if vm
      Puppet.warn("Could not configure CPU and memory for VM: %s because virtual machine creation failed." % vm_name) unless vm
    end

    power_state = resource[:power_state].to_sym
  end

  # This method creates a VMware Virtual Machine instance based on the specified base image
  # or the base image template name. The existing baseline Virtual Machine, must be available
  # on a shared data-store and must be visible on all ESX hosts. The Virtual Machine capacity
  # is allcoated based on the "numcpu" and "memorymb" parameter values, that are speicfied in the input file.
  def clone_vm

    resource[:network_interfaces] = resource[:network_interfaces].reject do |n|
      n['portgroup']== 'VM Network'
    end

    vm_name = resource[:name]

    dc = vim.serviceInstance.find_datacenter(resource[:template_datacenter])
    template = findvm(dc.vmFolder, resource[:template]) or raise(Puppet::Error, "Unable to find template #{resource[:template]}.")
    template_cd_drive = template.config.hardware.device.select{ |d|d.deviceInfo.label.include?("CD/DVD")}

    vm_devices=[]
    if resource[:network_interfaces]
      template_networks = template.config.hardware.device.collect{|x| x if x.class < RbVmomi::VIM::VirtualEthernetCard}.compact
      delete_network_specs = template_networks.collect do |nic|
        RbVmomi::VIM.VirtualDeviceConfigSpec(
          :device => nic,
          :operation =>  RbVmomi::VIM.VirtualDeviceConfigSpecOperation('remove')
        )
      end
      vm_devices.push(*delete_network_specs)
      vm_devices.push(*network_specs)
      vm_devices.push(*cdrom_spec) if template_cd_drive.empty?
    end

    config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
      :name => vm_name,
      :memoryMB => resource[:memory_mb],
      :numCPUs => resource[:num_cpus],
      :numCoresPerSocket => resource[:num_cpus],
      :deviceChange => vm_devices
    )

    if resource[:guest_custom_spec]
      # get the vm custom spec from the inventory
      specManager = vim.serviceContent.customizationSpecManager
      vm_custom_spec_name = resource[:guest_custom_spec]
      customization = specManager.GetCustomizationSpec(:name => vm_custom_spec_name)
      if customization.nil?
        raise(Puppet::Error, "SpecManager could not find the guest customization spec, '#{vm_custom_spec_name}'")
      end
      spec = RbVmomi::VIM.VirtualMachineCloneSpec(
        :location => relocate_spec,
        :powerOn => (resource[:power_state] == :poweredOn),
        :template => false,
        :customization => customization.spec,
        :config => config_spec
      )
    elsif resource[:guest_customization].to_s == 'true'
      Puppet.notice "Customizing the guest OS."
      # Calling getguestcustomization_spec method in case guestcustomization
      # parameter is specified with value true
      network_interfaces = template.summary.config.numEthernetCards
      spec = RbVmomi::VIM.VirtualMachineCloneSpec(
        :location => relocate_spec,
        :powerOn => (resource[:power_state] == :poweredOn),
        :template => false,
        :customization => customization_spec(network_interfaces),
        :config => config_spec
      )
    else
      spec = RbVmomi::VIM.VirtualMachineCloneSpec(
        :location => relocate_spec,
        :powerOn => (resource[:power_state] == :poweredOn),
        :template => false,
        :config => config_spec
      )
    end

    template.CloneVM_Task(
      :folder => datacenter.vmFolder,
      :name => vm_name,
      :spec => spec
    ).wait_for_completion
  end

  def datastore_object(datastore_name)
    datastore_name = datastore_name.is_a?(Hash) ? datastore_name["name"] : datastore_name
    cluster.datastore.find { |ds| "[#{ds.name}]" == datastore_name || ds.name == datastore_name}
  end

  def findvm(folder, vm_name)
    folder.children.each do |f|
      case f
      when RbVmomi::VIM::Folder
        findvm(f, vm_name)
      when RbVmomi::VIM::VirtualMachine
        return f if f.name == vm_name
      when RbVmomi::VIM::VirtualApp
        f.vm.each do |v|
        return f if v.name == vm_name
        end
      else
        raise(Puppet::Error, "unknown child type found: #{f.class}")
      end
    end

    nil
  end

  def datacenter(name=resource[:datacenter])
    @datacenter ||= vim.serviceInstance.find_datacenter(name) or raise(Puppet::Error, "datacenter '#{name}' not found.")
  end

  def vm
    @vm ||= findvm(datacenter.vmFolder, resource[:name])
  end

  def dvswitch(dv_switch_name)
    dvswitches = datacenter.networkFolder.children.select {|n|
      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
    }
    dvswitches.find{|d| d.name == dv_switch_name}
  end

  def dvswitch_uuid(dv_switch_uuid)
    dvswitches = datacenter.networkFolder.children.select {|n|
      n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
    }
    dvswitches.find{|d| d.uuid == dv_switch_uuid}
  end

  def dvportgroup(dv_switch_name, dv_port_group_name)
    name = dv_port_group_name
    dvs_name = dv_switch_name
    pg =
      if datacenter
        pg =
          datacenter.networkFolder.children.select{|n|
            n.class == RbVmomi::VIM::DistributedVirtualPortgroup
          }.
              find_all{|pg| pg.name == name}.
              tap{|all| @dvportgroup_list = all}.
              find{|pg| pg.config.distributedVirtualSwitch.name == dvs_name}
        if pg.nil? && (@dvportgroup_list.size != 0)
          owner = @dvportgroup_list.first.config.distributedVirtualSwitch.name
          fail "dvportgroup '#{name}' owned by dvswitch '#{owner}', "\
             "is not available for '#{dvs_name}'"
        end
        pg
      else
        nil
      end
    pg
  end

  def dvportgroup_portkey(dv_switch_name, dv_port_group_key)
    name = dv_port_group_key
    dvs_name = dv_switch_name
    pg =
        if datacenter
          pg =
              datacenter.networkFolder.children.select{|n|
                n.class == RbVmomi::VIM::DistributedVirtualPortgroup
              }.
                  find_all{|pg| pg.key == name}.
                  tap{|all| @dvportgroup_list = all}.
                  find{|pg| pg.config.distributedVirtualSwitch.name == dvs_name}
          if pg.nil? && (@dvportgroup_list.size != 0)
            owner = @dvportgroup_list.first.config.distributedVirtualSwitch.name
            fail "dvportgroup '#{name}' owned by dvswitch '#{owner}', "\
             "is not available for '#{dvs_name}'"
          end
          pg
        else
          nil
        end
    pg
  end

end
