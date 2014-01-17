# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Virtual Machines."
  # Method to create new VM
  def create
    flag = 0
    begin

      operation_name = get_operation_name
      # Calling create_vm functionality

      create_vm if operation_name.eql?('create')
      clone_vm if operation_name.eql?('clone')

    rescue Exception => exc
      flag = 1
      Puppet.err(exc.message)
    end
    check_vm(flag)
  end
  def check_vm(flag)
    vm_name = resource[:name]
    if flag != 1
          # Validate if VM is cloned successfully.
          if vm
            Puppet.notice "Successfully cloned the Virtual Machine '#{vm_name}'."
          else
            Puppet.err "Unable to clone the Virtual Machine '#{vm_name}'."
          end
    
        end
  end
  
  def get_operation_name
    return resource[:operation].to_s
  end

  # Method to create vm guestcustomization spec
  def getguestcustomization_spec ( vm_adaptercount )
    guest_hostname = resource[:guesthostname]
    if guest_hostname
      temp_vmname = guest_hostname
    else
      temp_vmname = resource[:name]
    end

    custom_host_name = RbVmomi::VIM.CustomizationFixedName(:name => temp_vmname )

    dns_domain = resource[:dnsdomain]

    guesttypeflag = resource[:guesttype]
    guesttypeflag = guesttypeflag.to_s
    if guesttypeflag.eql?('windows')
      # Creating custom specification for windows
      cust_prep = get_cs_win (custom_host_name)
    else
      # for linux
      cust_prep = RbVmomi::VIM.CustomizationLinuxPrep(:domain => dns_domain,
      :hostName => custom_host_name,
      :timeZone => resource[:linuxtimezone])
    end

    customization_global_settings = RbVmomi::VIM.CustomizationGlobalIPSettings

    #Creating NIC specification
    cust_adapter_mapping_arr = get_nics(vm_adaptercount)

    customization_spec = RbVmomi::VIM.CustomizationSpec(:identity => cust_prep,
    :globalIPSettings => customization_global_settings,
    :nicSettingMap=> cust_adapter_mapping_arr)
    return customization_spec
  end

  # Get Custom Spec for windows
  def get_cs_win (custom_host_name)
    guestwindowsdomain_administrator = resource[:guestwindowsdomainadministrator]
    guestwindowsdomain_adminpassword = resource[:guestwindowsdomainadminpassword]
    dns_domain = resource[:dnsdomain]
    product_id = resource[:productid]

    if dns_domain.strip.length > 0 and
    guestwindowsdomain_administrator.strip.length > 0 and
    guestwindowsdomain_adminpassword.strip.length > 0

      if product_id.strip.length == 0
        raise Puppet::Error, "Product ID cannot be blank."
        return nil
      end

      domain_adminpassword = RbVmomi::VIM.CustomizationPassword(:plainText=>true,
      :value=> guestwindowsdomain_adminpassword)
      cust_identification = RbVmomi::VIM.CustomizationIdentification(:domainAdmin => guestwindowsdomain_administrator,
      :domainAdminPassword => domain_adminpassword ,
      :joinDomain => dns_domain)
    else
      cust_identification = RbVmomi::VIM.CustomizationIdentification
    end

    windows_adminpassword = resource[:windowsadminpassword]

    win_timezone = resource[:windowstimezone]
    autologon = resource[:autologon]
    autologoncount = resource[:autologoncount]

    if windows_adminpassword.strip.length > 0
      admin_password =  RbVmomi::VIM.CustomizationPassword(:plainText=>true, :value=> windows_adminpassword )
      cust_gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(:autoLogon => autologon,
      :password => admin_password, :autoLogonCount => autologoncount, :timeZone => win_timezone)
    else
      cust_gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(:autoLogon => autologon,
      :autoLogonCount => autologoncount, :timeZone => win_timezone)
    end

    cust_user_data = RbVmomi::VIM.CustomizationUserData(:computerName => custom_host_name,
    :fullName => resource[:windowsguestowner], :orgName => resource[:windowsguestorgnization],
    :productId => product_id)

    customlicensedatamode = resource[:customizationlicensedatamode]
    customlicense_datamode = RbVmomi::VIM.CustomizationLicenseDataMode(customlicensedatamode);

    if customlicensedatamode.eql?('perServer')
      autousers = resource[:autousers]
      licensefile_printdata = RbVmomi::VIM.CustomizationLicenseFilePrintData(:autoMode => customlicense_datamode,
      :autoUsers => autousers)
    else
      licensefile_printdata = RbVmomi::VIM.CustomizationLicenseFilePrintData(:autoMode => customlicense_datamode)
    end

    cust_prep = RbVmomi::VIM.CustomizationSysprep(:guiUnattended => cust_gui_unattended,
    :identification => cust_identification, :licenseFilePrintData => licensefile_printdata,
    :userData => cust_user_data)

    return cust_prep

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
      customization_fixed_ip = RbVmomi::VIM.CustomizationFixedIp(:ipAddress => ip_address)
    else
      customization_fixed_ip = RbVmomi::VIM.CustomizationDhcpIpGenerator
    end

    cust_ip_settings = RbVmomi::VIM.CustomizationIPSettings(:ip => customization_fixed_ip ,
    :subnetMask => subnet , :dnsServerList => dnsserver_arr , :gateway => gateway_arr,
    :dnsDomain => resource[:dnsdomain] )

    return cust_ip_settings

  end

  # Method to create VM relocate spec
  def createrelocate_spec
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter_name])

    cluster_name = resource[:cluster]
    host_ip = resource[:host]
    target_datastore = resource[:target_datastore]

    checkfor_ds = "true"
    relocate_spec = nil
    if cluster_name and cluster_name.strip.length != 0
      relocate_spec = rs_cluster(dc,cluster_name)

    elsif host_ip and host_ip.strip.length != 0
      relocate_spec = rs_host(dc,host_ip)

    else
      checkfor_ds = "false"
      # Neither host not cluster name is provided. Getting the relocate specification
      # from VM view
      relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec
    end
    if checkfor_ds.eql?('true') and !relocate_spec.nil?
      relocate_spec = rs_datastore(dc,target_datastore,relocate_spec)
    end

    return relocate_spec
  end

  # Method to create vm relocate spec if cluster name is provided
  def rs_cluster(dc,cluster_name)
    cluster_relocate_spec = nil
    cluster ||= dc.find_compute_resource(cluster_name)
    if !cluster
      raise Puppet::Error, "Unable to find the cluster '#{cluster_name}' because the cluster is either invalid or does not exist."
    else
      cluster_relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:pool => cluster.resourcePool)
    end
    return cluster_relocate_spec

  end

  # Method to update vm relocate spec if target datastore name is provided
  def rs_datastore(dc,target_datastore, relocate_spec)
    if target_datastore and target_datastore.strip.length != 0
      ds ||= dc.find_datastore(target_datastore)
      if !ds
        raise Puppet::Error, "Unable to find the target datastore '#{target_datastore}' because the target datastore is either invalid or does not exist."
        relocate_spec = nil
      else
        relocate_spec.datastore = ds
      end
    end
    return relocate_spec

  end

  # Method to create vm relocate spec if host ip is provided
  def rs_host(dc,host_ip)
    host_relocate_spec = nil

    host_view = vim.searchIndex.FindByIp(:datacenter => dc , :ip => host_ip, :vmSearch => false)

    if !host_view
      raise Puppet::Error, "Unable to find the host '#{host_ip}' because the host is either invalid or does not exist."
    else

      disk_format =  resource[:diskformat]
      updated_diskformat = "sparse"
      # Need to update updated_diskformat value if disk_format is set to thick
      updated_diskformat = "flat" if disk_format.eql?('thick')
      transform = RbVmomi::VIM.VirtualMachineRelocateTransformation(updated_diskformat);
      host_relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view, :pool => host_view.parent.resourcePool,
      :transform => transform)
    end
    return host_relocate_spec
  end

  # Method to delete VM from vCenter
  def destroy
    vm_name = resource[:name]
    virtualmachine_obj = get_vm_from_datacenter
    Puppet.err("Unable to find Virtual Machine.") if virtualmachine_obj.eql?(nil)
    vmpower_state = get_power_state(virtualmachine_obj)
    Puppet.notice "Virtual Machine is already in powered Off state." if vmpower_state.eql?('poweredOff')
    Puppet.notice "Virtual Machine is in suspended state." if vmpower_state.eql?('suspended')
    delete_vm(virtualmachine_obj)
  end

  def get_power_state(virtualmachine_obj)
    return virtualmachine_obj.runtime.powerState
  end

  def delete_vm(virtualmachine_obj)
    vmpower_state = get_power_state(virtualmachine_obj)
    if vmpower_state.eql?('poweredOn')
          Puppet.notice "Virtual Machine is in powered On state. Need to power it Off."
          virtualmachine_obj.PowerOffVM_Task.wait_for_completion
        end
        virtualmachine_obj.Destroy_Task.wait_for_completion
  end
  
  def get_vm_from_datacenter
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter_name])
    return  dc.find_vm(resource[:name])
  end

  def exists?
    vm
  end

  # Get the power state.
  def power_state
    Puppet.debug "Retrieving the power state of the virtual machine."
    begin
      # Did not use '.guest.powerState' since it only works if vmware tools are running.
      vm.runtime.powerState
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

  # Set the power state.
  def power_state=(value)
    Puppet.debug "Setting the power state of the virtual machine."
    begin

      # Perform operations if desired power_state=:poweredOff
      if value == :poweredOff
        if ((vm.guest.toolsStatus != 'toolsNotInstalled') or (vm.guest.toolsStatus != 'toolsNotRunning')) and resource[:graceful_shutdown] == :true
          vm.ShutdownGuest
          # Since vm.ShutdownGuest doesn't return a task we need to poll the VM powerstate before returning.
          attempt = 5  # let's check 5 times (1 min 15 seconds) before we forcibly poweroff the VM.
          while power_state != "poweredOff" and attempt > 0
            sleep 15
            attempt -= 1
          end
          vm.PowerOffVM_Task.wait_for_completion if power_state != "poweredOff"
        else
          vm.PowerOffVM_Task.wait_for_completion
        end
        # Perform operations if desired power_state=:poweredOn
      elsif value == :poweredOn
        vm.PowerOnVM_Task.wait_for_completion
        # Perform operations if desired power_state=:suspend
      elsif value == :suspended
        if power_state == "poweredOn"
          vm.SuspendVM_Task.wait_for_completion
        else
          raise Puppet::Error, "Unable to suspend the virtual machine because the virtual machine is in powered Off state."
        end
        # Perform operations if desired power_state=:reset
      elsif value == :reset
        if power_state !~ /poweredOff|suspended/i
          vm.ResetVM_Task.wait_for_completion
        else
          raise Puppet::Error, "Unable to reset the virtual machine because the virtual machine is powered Off or suspended. Make sure that the virtual machine is powered On."
        end
      end
    rescue Exception => excep
      Puppet.err "Unable to perform the operation because the following exception occurred."
      Puppet.err excep.message
    end
  end

  # This method creates a new virtual machine,instead of cloning a virtual machine from an existing one.

  def create_vm

    datacenter = resource[:datacenter_name]
    dc = vim.serviceInstance.find_datacenter(datacenter)
    vm_devices = []
    target_datastore = resource['target_datastore']
    if !dc.find_datastore(target_datastore)
      raise Puppet::Error, "Unable to find the target datastore '#{target_datastore}' because the target datastore is either invalid or does not exist."
    end
    ds_path = "[#{target_datastore}]"

    # calling controller_vm_dev_conf_spec method to create controller vm dev conf spec
    controller_vm_dev_conf_spec = create_conf_spec
    # calling disk_vm_dev_conf_spec method to create disk vm dev conf spec
    disk_vm_dev_conf_spec = create_virtual_disk(ds_path)
    vm_devices.push(controller_vm_dev_conf_spec, disk_vm_dev_conf_spec)

    # Getting nic specification for each nic
    1.upto(resource[:nic_count]) do |count|
      vm_devices.push( get_network_config(count))
    end

    config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(:name => resource[:name], :memoryMB => resource[:memorymb],
    :numCPUs => resource[:numcpu] , :guestId => resource[:guestid], :files => { :vmPathName => ds_path },
    :memoryHotAddEnabled => resource[:memory_hot_add_enabled], :cpuHotAddEnabled => resource[:cpu_hot_add_enabled],
    :deviceChange => vm_devices  )

    cluster_name = resource[:cluster]
    if cluster_name and cluster_name.strip.length != 0
      # Getting the pool information from cluster
      cluster = dc.find_compute_resource(cluster_name)
      raise Puppet::Error, "Unable to find the cluster '#{cluster_name}' because the cluster is either invalid or does not exist." if !cluster
      resource_pool = cluster.resourcePool
    else
      # Getting the pool from host view
      host_ip = resource[:host]
      host_view = vim.searchIndex.FindByIp(:datacenter => dc , :ip => host_ip , :vmSearch => false)
      raise Puppet::Error, "Unable to find the host '#{host_ip}' because the host is either invalid or does not exist." if !host_view
      resource_pool = host_view.parent.resourcePool
    end

    dc.vmFolder.CreateVM_Task(:config => config_spec, :pool => resource_pool).wait_for_completion

  end

  #    # create virtual device config spec for controller
  def create_conf_spec
    controller = RbVmomi::VIM.VirtualBusLogicController(:key => 0,:device => [0], :busNumber => 0,
    :sharedBus => RbVmomi::VIM.VirtualSCSISharing('noSharing'))

    controller_vm_dev_conf_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(:device => controller,
    :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add'))

    return controller_vm_dev_conf_spec
  end

  #  create virtual device config spec for disk
  def create_virtual_disk(ds_path)

    thin_provisioning = true
    # Need to set the value to false if user has provided diskformat value as thick
    thin_provisioning = false if resource[:diskformat].eql?('thick')
    disk_backing_info = RbVmomi::VIM.VirtualDiskFlatVer2BackingInfo(:diskMode => 'persistent',
    :fileName => ds_path , :thinProvisioned => thin_provisioning )

    disk = RbVmomi::VIM.VirtualDisk(:backing => disk_backing_info, :controllerKey => 0,
    :key => 0, :unitNumber => 0, :capacityInKB => resource[:disksize])

    disk_vm_dev_conf_spec =  RbVmomi::VIM.VirtualDeviceConfigSpec(:device => disk,
    :fileOperation => RbVmomi::VIM.VirtualDeviceConfigSpecFileOperation('create'),
    :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add'))
    return disk_vm_dev_conf_spec
  end

  # get network configuration
  def get_network_config(count)

    port_group =  resource[:portgroup]

    backing = RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(:deviceName => port_group)
    nic_type = resource[:nic_type].to_s

    if nic_type.eql?("E1000")

      nic = RbVmomi::VIM.VirtualE1000({
        :key => count, :backing => backing ,
        :deviceInfo => {:label => "Network Adapter",:summary => port_group }})
    elsif nic_type.eql?("VMXNET 3")
      nic = RbVmomi::VIM.VirtualVmxnet3({
        :key => count,:backing => backing ,
        :deviceInfo => { :label => "Network Adapter", :summary => port_group }})
    else
      nic = RbVmomi::VIM.VirtualVmxnet2({
        :key => count,:backing => backing ,
        :deviceInfo => {:label => "Network Adapter", :summary => port_group}})
    end

    nic_config = RbVmomi::VIM.VirtualDeviceConfigSpec(:device => nic, :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add'))

    return nic_config
  end

  # This method creates a VMware Virtual Machine instance based on the specified base image
  # or the base image template name. The existing baseline Virtual Machine, must be available
  # on a shared data-store and must be visible on all ESX hosts. The Virtual Machine capacity
  # is allcoated based on the "numcpu" and "memorymb" parameter values, that are speicfied in the input file.
  def clone_vm
    dc_name = resource[:datacenter_name]
    goldvm_dc_name = resource[:goldvm_datacenter]
    vm_name = resource[:name]
    source_dc = vim.serviceInstance.find_datacenter(goldvm_dc_name)
    virtualmachine_obj = source_dc.find_vm(resource[:goldvm]) or abort "Unable to find Virtual Machine."
    goldvm_adapter = virtualmachine_obj.summary.config.numEthernetCards
    # Calling createrelocate_spec method
    relocate_spec = createrelocate_spec
    if relocate_spec.nil?
      raise Puppet::Error, "Unable to retrieve the specification required to relocate the Virtual Machine."
    end

    config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(:name => vm_name, :memoryMB => resource[:memorymb],
    :numCPUs => resource[:numcpu])

    guestcustomizationflag = resource[:guestcustomization]
    guestcustomizationflag = guestcustomizationflag.to_s

    if guestcustomizationflag.eql?('true')
      Puppet.notice "Customizing the guest OS."
      # Calling getguestcustomization_spec method in case guestcustomization
      # parameter is specified with value true
      customization_spec_info = getguestcustomization_spec ( goldvm_adapter )
      if customization_spec_info.nil?
        raise Puppet::Error, "Unable to retrieve the specification required for Virtual Machine customization."
      end
      spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocate_spec, :powerOn => false,
      :template => false, :customization => customization_spec_info, :config => config_spec)
    else
      spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocate_spec, :powerOn => false,
      :template => false, :config => config_spec)
    end

    dc = vim.serviceInstance.find_datacenter(dc_name)
    virtualmachine_obj.CloneVM_Task( :folder => dc.vmFolder, :name => vm_name ,
    :spec => spec).wait_for_completion

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
        Puppet.err
        "unknown child type found: #{f.class}"
        exit
      end
    end
    @vm_obj
  end

  def datacenter(name=resource[:datacenter_name])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
  end

  def vm
    # findvm(datacenter.vmFolder,resource[:name])
    @vm ||= findvm(datacenter.vmFolder, resource[:name])
  end
end
