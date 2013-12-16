# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter Virtual Machines."

  def create
    flag = 0
    begin
      dc_name = resource[:datacenter]
      vm_name = resource[:name]
      dc = vim.serviceInstance.find_datacenter(dc_name)
      virtualmachine_obj = dc.find_vm(resource[:goldvm]) or abort "Unable to find Virtual Machine."
      goldvm_adapter = virtualmachine_obj.summary.config.numEthernetCards
      # Calling createrelocate_spec method
      relocate_spec = createrelocate_spec
      if relocate_spec.nil?
        raise Puppet::Error, "Unable to retrieve the specification required to relocate the Virtual Machine."
      end

      config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(:name => vm_name, :memoryMB => resource[:memorymb],
      :numCPUs => resource[:numcpu])

      if resource[:guestcustomization].eql?('true')
        Puppet.info "Customizing the guest OS."
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

      virtualmachine_obj.CloneVM_Task( :folder => virtualmachine_obj.parent, :name => vm_name ,
      :spec => spec).wait_for_completion
    rescue Exception => exc
      flag = 1
      Puppet.err(exc.message)
    end
    if flag != 1
      # Validate if VM is cloned successfully.
      if vm
          Puppet.info "Successfully cloned the Virtual Machine '"+vm_name+"'."
      else
          Puppet.err "Unable to clone the Virtual Machine '"+vm_name+"'."
      end
     
    end
  end

  def getguestcustomization_spec ( vm_adaptercount )
    guest_hostname = resource[:guesthostname]
    if guest_hostname
      temp_vmname = guest_hostname
    else
      temp_vmname = resource[:name]
    end

    custom_host_name = RbVmomi::VIM.CustomizationFixedName(:name => temp_vmname )
    guestwindowsdomain_administrator = resource[:guestwindowsdomainadministrator]
    guestwindowsdomain_adminpassword = resource[:guestwindowsdomainadminpassword]
    dns_domain = resource[:dnsdomain]
    if resource[:guesttype].eql?('windows')
      # Creating custom specification for windows
      cust_prep = get_cs_win
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
  def get_cs_win

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

    if windows_adminpassword.strip.length > 0
      admin_password =  RbVmomi::VIM.CustomizationPassword(:plainText=>true, :value=> windows_adminpassword )
      cust_gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(:autoLogon => 1,
      :password => admin_password, :autoLogonCount => 1, :timeZone => win_timezone)
    else
      cust_gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(:autoLogon => resource[:autologon],
      :autoLogonCount => resource[:autologoncount], :timeZone => win_timezone)
    end

    cust_user_data = RbVmomi::VIM.CustomizationUserData(:computerName => custom_host_name,
    :fullName => resource[:windowsguestowner], :orgName => resource[:windowsguestorgnization],
    :productId => product_id)

    customlicense_datamode = RbVmomi::VIM.CustomizationLicenseDataMode(resource[:customizationlicensedatamode]);
    licensefile_printdata = RbVmomi::VIM.CustomizationLicenseFilePrintData(:autoMode => customLicenseDataMode,
    :autoUsers => 5)

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

      if key == "ip"
        ip_address = value
      end

      if key == "subnet"
        subnet = value
      end

      if key == "dnsserver"
        dnsserver = value
        dnsserver_arr = Array [ dnsserver ]
      end

      if key == "gateway"
        gateway = value
        gateway_arr = Array [ gateway ]
      end
    }

    if ip_address
      customization_fixed_ip = RbVmomi::VIM.CustomizationFixedIp(:ipAddress => ip_address)
    else
      customization_fixed_ip = RbVmomi::VIM.CustomizationDhcpIpGenerator
    end

    cust_ip_settings = RbVmomi::VIM.CustomizationIPSettings(:ip => customization_fixed_ip ,
    :subnetMask => subnet , :dnsServerList => dnsserver_arr , :gateway => gateway_arr,
    :dnsDomain => dns_domain )

    return cust_ip_settings

  end

  def createrelocate_spec
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])

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
    if checkfor_ds.eql?(true) and !relocate_spec.nil?
      relocate_spec = rs_datastore(dc,target_datastore,relocate_spec)
    end

    return relocate_spec
  end

  def rs_cluster(dc,cluster_name)
    cluster_relocate_spec = nil
    cluster ||= dc.find_compute_resource(cluster_name)
    if !cluster
      raise Puppet::Error, "Unable to find the cluster '"+cluster_name+"'because the cluster is either invalid or does not exist."
    else
      cluster_relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:pool => cluster.resourcePool)
    end
    return cluster_relocate_spec

  end

  def rs_datastore(dc,target_datastore, relocate_spec)
    if target_datastore and target_datastore.strip.length != 0
      ds ||= dc.find_datastore(target_datastore)
      if !ds
        raise Puppet::Error, "Unable to find the target datastore '"+target_datastore+"'because the target datastore is either invalid or does not exist."
        relocate_spec = nil
      else
        relocate_spec.datastore = ds
      end
    end
    return relocate_spec

  end

  # Relocate spec for host
  def rs_host(dc,host_ip)
    host_relocate_spec = nil

    host_view = vim.searchIndex.FindByIp(:datacenter => dc , :ip => host_ip, :vmSearch => false)

    if !host_view
      raise Puppet::Error, "Unable to find the host '"+host_ip+"'because the host is either invalid or does not exist."
    else

      disk_format =  resource[:diskformat]
      if disk_format.eql?('thin')
        updated_diskformat = "sparse"
      elsif disk_format.eql?('thick')
        updated_diskformat = "flat"
      else
        updated_diskformat = "sparse"
      end

      transform = RbVmomi::VIM.VirtualMachineRelocateTransformation(updated_diskformat);
      host_relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view, :pool => host_view.parent.resourcePool,
      :transform => transform)
    end
    return host_relocate_spec
  end

  def destroy
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
    vm_name = resource[:name]

    if dc
      virtualmachine_obj = nil
      if vm_name
        virtualmachine_obj = dc.find_vm(vm_name)
      end

      if virtualmachine_obj
        vmPower_state = virtualmachine_obj.runtime.powerState
        if vmPower_state.eql?('poweredOff')
          Puppet.info "Virtual Machine is already powered off."
        elsif vmPower_state.eql?('poweredOn')
          Puppet.info "Virtual Machine is powered on.Need to power it off."
          virtualmachine_obj.PowerOffVM_Task.wait_for_completion
        elsif vmPower_state.eql?('suspended')
          Puppet.info "Virtual Machine is suspended."
        end
      else
        puppet.err("Unable to find Virtual Machine.")
      end
    end
    virtualmachine_obj.Destroy_Task.wait_for_completion
  end

  def exists?
    vm
  end

  # Get the power state.
  def power_state
    puts "Retrieving the power state of the Virtual Machine."
    puts caller[0]
    begin
      # Did not use '.guest.powerState' since it only works if vmware tools are running.
      vm.runtime.powerState
    rescue Exception => exception
      puts exception.message
    end
  end

  # Set the power state.
  def power_state=(value)
    puts "Setting the power state of the Virtual Machine."
    begin

      # perform operations if desired power_state=:poweredOff
      if value == :poweredOff
        if power_state != "poweredOff"
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
            if power_state != "poweredOff"
              vm.PowerOffVM_Task.wait_for_completion
            else
              puts "Unable to power Off the Virtual Machine because the Virtual Machine is already in powered Off state."
            end
          end
        elsif power_state == "poweredOff"
          puts "Unable to power Off the Virtual Machine because the Virtual Machine is already in powered Off state."
        end

        # perform operations if desired power_state=:poweredOn
      elsif value == :poweredOn
        if power_state != "poweredOn"
          vm.PowerOnVM_Task.wait_for_completion
        elsif power_state == "poweredOn"
          puts "Unable to power On the Virtual Machine because the Virtual Machine is already in powered On state."
        end

        # perform operations if desired power_state=:suspend
      elsif value == :suspend
        if power_state != "poweredOff"
          vm.SuspendVM_Task.wait_for_completion
        elsif power_state == "poweredOff"
          puts "Unable to power Off the Virtual Machine because the Virtual Machine is already in powered Off state."
        end

        # perform operations if desired power_state=:reset
      elsif value == :reset
        if power_state != "poweredOff"
          vm.ResetVM_Task.wait_for_completion
        else
          puts "Unable to reset the Virtual Machine because the Virtual Machine is powered Off. Make sure that the Virtual Machine is powered On."
        end

      end

    rescue Exception => exception
      flag = 1
      puts "Unable to perform the operation because the following exception occurred."
      puts exception.message
    end
  end

  private

  def vm
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      @vmObj ||= dc.find_vm(resource[:name])
    rescue Exception => excep
      Puppet.err excep.message
    end
  end
end
