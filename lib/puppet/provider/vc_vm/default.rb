# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require File.join(provider_path, 'spbmapiutils')

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = 'Manages vCenter Virtual Machines.'

  def exists?
    vm
  end

  def srm
    @srm ||= vim.serviceInstance.content.storageResourceManager
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

  def network_interfaces=(config)
    network_spec = network_adapter_spec
    Puppet.debug("Expected final network_spec #{network_spec.inspect}")
    if network_spec.size != 0
      vm_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
        :name => resource[:name],
        :deviceChange => network_spec
      )
       vm.ReconfigVM_Task(
         :spec => vm_spec
         ).wait_for_completion
      # No need to reset the VM in case existing and new network count is the same
      # We are just changing the port-group mapping
      if power_state == "poweredOn"
         #need to give vcenter a chance to reconfigure before rebooting
         sleep 15
         vm.ResetVM_Task.wait_for_completion
      end
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
    if resource[:template]
      clone_vm
    else
      create_vm
    end
    raise(Puppet::Error, "Unable to create VM: '#{resource[:name]}'") unless vm
  end

  def destroy
    if power_state == 'poweredOn'
      Puppet.notice "Powering off VM #{resource[:name]} prior to removal."
      vm.PowerOffVM_Task.wait_for_completion
    else
      Puppet.debug "Virtual machine state: #{power_state}"
    end
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
    @host ||= vim.searchIndex.FindByIp(:datacenter => datacenter , :ip => resource[:host], :vmSearch => false) or raise(Puppet::Error, "Unable to find the host '#{resource[:host]}'")
  end

  def get_cluster_datastore
    requested_datastore = (resource[:datastore] || '')
    
    # Disk size is in KB and the information coming back from 
    # API is in Bytes
    if resource[:virtual_disks]
      requested_size = 0
      # virtual_disks size is originally in gb
      resource[:virtual_disks].each{ |disk| requested_size += disk["size"].to_i * 1024 * 1024}
      requested_size  *= 1024
    else
      requested_size = resource[:disk_size].to_i * 1024
    end

    paths = %w(name info.url info summary summary.accessible summary.capacity summary.freeSpace)
    propSet = [{ :type => 'Datastore', :pathSet => paths }]
    filterSpec = { :objectSet => cluster.datastore.map { |ds| { :obj => ds } }, :propSet => propSet }
    data = vim.propertyCollector.RetrieveProperties(:specSet => [filterSpec])
    datastore_info = data.map do |d|
      size = d['summary.capacity']
      free = d['summary.freeSpace']
      used = size - free
      is_local = d['name'].match(/local-storage-\d+/)
      info = {
          'name' => d['name'], 'size' => size, 'free' => free, 'used' => used,
          'info' => d['info'], 'summary' => d['summary'], 'is_local' => is_local
      }
      info if d['summary.accessible'] && (resource[:skip_local_datastore] == :false || !is_local)
    end
    datastore_info += get_cluster_storage_pods
    datastore_info.compact!

    #Sort order: Pod -> Remote Datastore -> Local Datastore (each sorted by free size)
    datastore_info.sort_by! {|h| [h["pod"] ? 0 : 1, h["is_local"] ? 1 : 0, -h["free"]]}

    Puppet.debug("Datastore info: #{datastore_info}")
    Puppet.debug("Requested size: #{requested_size}")
    if !requested_datastore.empty?
      info = datastore_info.find { |d| d['name'] == requested_datastore }
      raise("Datastore #{requested_datastore} not found") unless info
      raise("In-sufficient space in datastore #{requested_datastore}") unless free < requested_size
      requested_datastore
    else
      datastore_selected = datastore_info.find { |d| d['free'] >= requested_size }
      raise("No datastore found with sufficient free space") unless datastore_selected
      Puppet.debug("Selected datastore: #{datastore_selected['name']}")
      # Why are we putting [] around the name in this case??
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
    config = {
        :name => resource[:name],
        :memoryMB => resource[:memory_mb],
        :numCPUs => resource[:num_cpus] ,
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
    datastore.match(/vsanDatastore/)
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

    RbVmomi::VIM.VirtualDeviceConfigSpec(
      :device => disk,
      :fileOperation => RbVmomi::VIM.VirtualDeviceConfigSpecFileOperation('create'),
      :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
    )
  end

  # get network configuration
  def network_specs(interfaces=resource[:network_interfaces], action='add')
    interfaces.each_with_index.collect do |nic, index|
      portgroup = nic['portgroup']
      if portgroup.match(/(\S+)\s*\((\S+)\)/)
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
    end

    config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
      :name => vm_name,
      :memoryMB => resource[:memory_mb],
      :numCPUs => resource[:num_cpus],
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
    cluster.datastore.find { |ds| ds_obj = ds if "[#{ds.name}]" == datastore_name}
  end

  private

  def findvm(folder,vm_name)
    folder.children.each do |f|
      break if @vm_obj
      case f
      when RbVmomi::VIM::Folder
        findvm(f,vm_name)
      when RbVmomi::VIM::VirtualMachine
        @vm_obj = f if f.name == vm_name
      when RbVmomi::VIM::VirtualApp
        f.vm.each do |v|
          if v.name == vm_name
            @vm_obj = f
            break
          end
        end
      else
        raise(Puppet::Error, "unknown child type found: #{f.class}")
      end
    end
    @vm_obj
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
