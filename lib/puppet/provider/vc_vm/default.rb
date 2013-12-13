# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:vc_vm).provide(:vc_vm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs."
  def create
    flag = 0
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      virtualMachineObj = dc.find_vm(resource[:goldvm]) or abort "VM not found"

      goldVMAdapter = virtualMachineObj.summary.config.numEthernetCards

      # Calling createRelocateSpec method
      relocateSpec    = createRelocateSpec
      if relocateSpec == nil
        raise Puppet::Error, "Unable to get VM relocate spec."
      end

      config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(:name => resource[:name],
      :memoryMB => resource[:memorymb],
      :numCPUs => resource[:numcpu])

      if resource[:guestcustomization].eql?('true')
        puts "Performing guest customization."

        # Calling getGuestCustomizationSpec method in case guestcustomization
        # parameter is specified with value true
        customization_spec_info = getGuestCustomizationSpec ( goldVMAdapter )

        if customization_spec_info == nil
          raise Puppet::Error, "Unable to get customization spec."
        end

        spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocateSpec,
        :powerOn => false,
        :template => false,
        :customization => customization_spec_info,
        :config => config_spec)
      else
        spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocateSpec,
        :powerOn => false,
        :template => false,
        :config => config_spec)
      end

      virtualMachineObj.CloneVM_Task( :folder => virtualMachineObj.parent,
      :name => resource[:name] ,
      :spec => spec).wait_for_completion
    rescue Exception => e
      flag = 1
      raise Puppet::Error, e.message
    end

    if flag == 1
      # Delete the VM as excetion occured.
      # puts "Delete the VM as excetion occured."
    else
      # Validate if VM is cloned successfully.
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])

      newVMObj = dc.find_vm(resource[:name])

      if defined?(newVMObj.name)
        puts "VM '"+resource[:name]+"' is cloned successfully."

        # Power on the clone VM.
        newVMObj.PowerOnVM_Task.wait_for_completion
      else
        raise Puppet::Error, "Failed to clone VM '"+resource[:name]+"'."
      end
    end
  end

  def getGuestCustomizationSpec ( numOfVMAdapter )
    if resource[:guesthostname]
      tempVMName = resource[:guesthostname]
    else
      tempVMName = resource[:name]
    end

    custom_host_name = RbVmomi::VIM.CustomizationFixedName(:name => tempVMName )

    if resource[:guesttype].eql?('windows')
      if resource[:productid].chomp.length == 0
        #raise Puppet::Error, "Product ID cannot be blank."
        #return nil
      end

      if resource[:dnsdomain].chomp.length > 0 and
      resource[:guestwindowsdomainadministrator].chomp.length > 0 and
      resource[:guestwindowsdomainadminpassword].chomp.length > 0

        domainAdminPassword = RbVmomi::VIM.CustomizationPassword(:plainText=>true,
        :value=> resource[:guestwindowsdomainadminpassword])
        cust_identification = RbVmomi::VIM.CustomizationIdentification(:domainAdmin => resource[:guestwindowsdomainadministrator],
        :domainAdminPassword => domainAdminPassword ,
        :joinDomain => resource[:dnsdomain])
      else
        cust_identification = RbVmomi::VIM.CustomizationIdentification
      end

      if resource[:windowsadminpassword].chomp.length > 0
        adminPassword =  RbVmomi::VIM.CustomizationPassword(:plainText=>true,
        :value=> resource[:windowsadminpassword] )
        cust_gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(:autoLogon => 1,
        :password => adminPassword,
        :autoLogonCount => 1,
        :timeZone => resource[:windowstimezone])
      else
        cust_gui_unattended = RbVmomi::VIM.CustomizationGuiUnattended(:autoLogon => 1,
        :autoLogonCount => 1,
        :timeZone => resource[:windowstimezone])
      end

      cust_name = RbVmomi::VIM.CustomizationFixedName(:name => tempVMName);

      cust_user_data = RbVmomi::VIM.CustomizationUserData(:computerName => cust_name,
      :fullName => resource[:windowsguestowner],
      :orgName => resource[:windowsguestorgnization],
      :productId => resource[:productid])

      customLicenseDataMode = RbVmomi::VIM.CustomizationLicenseDataMode('perServer');
      licenseFilePrintData = RbVmomi::VIM.CustomizationLicenseFilePrintData(:autoMode => customLicenseDataMode,
      :autoUsers => 5)

      cust_prep = RbVmomi::VIM.CustomizationSysprep(:guiUnattended => cust_gui_unattended,
      :identification => cust_identification,
      :licenseFilePrintData => licenseFilePrintData,
      :userData => cust_user_data)
    else

      cust_prep = RbVmomi::VIM.CustomizationLinuxPrep(:domain => resource[:dnsdomain],
      :hostName => custom_host_name,
      :timeZone => resource[:linuxtimezone])
    end

    customization_global_settings = RbVmomi::VIM.CustomizationGlobalIPSettings

    cust_adapter_mapping_arr = nil
    customization_spec = nil
    numOfNic = 0
    if resource[:nicspec]
      nicSpecHash = resource[:nicspec]

      if nicSpecHash["nic"]
        nicVal = nicSpecHash["nic"]
        numOfNic = nicVal.length

        if numOfNic > 0
          count = 0
          nicVal.each_index {
            |index, val|

            if count > numOfVMAdapter-1
              break
            end

            ipAddress = nil
            subnet = nil
            dnsserver = nil
            gateway = nil

            dnsServerArr = []
            gatewayArr = []

            nicVal[index].each_pair {
              |key, value|

              if key == "ip"
                ipAddress = value
              end

              if key == "subnet"
                subnet = value
              end

              if key == "dnsserver"
                dnsserver = value
                dnsServerArr = Array [ dnsserver ]
              end

              if key == "gateway"
                gateway = value
                gatewayArr = Array [ gateway ]
              end
            }

            if ipAddress
              customization_fixed_ip = RbVmomi::VIM.CustomizationFixedIp(:ipAddress => ipAddress)
            else
              customization_fixed_ip = RbVmomi::VIM.CustomizationDhcpIpGenerator
            end

            cust_ip_settings = RbVmomi::VIM.CustomizationIPSettings(:ip => customization_fixed_ip ,
            :subnetMask => subnet ,
            :dnsServerList => dnsServerArr ,
            :gateway => gatewayArr,
            :dnsDomain => resource[:dnsdomain] )

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
    remainingAdapter = numOfVMAdapter - numOfNic

    if remainingAdapter > 0
      customization_fixed_ip = RbVmomi::VIM.CustomizationDhcpIpGenerator
      cust_ip_settings = RbVmomi::VIM.CustomizationIPSettings(:ip => customization_fixed_ip )
      cust_adapter_mapping = RbVmomi::VIM.CustomizationAdapterMapping(:adapter => cust_ip_settings )
      cust_adapter_mapping_arr.push (cust_adapter_mapping)
    end

    customization_spec = RbVmomi::VIM.CustomizationSpec(:identity => cust_prep,
    :globalIPSettings => customization_global_settings,
    :nicSettingMap=> cust_adapter_mapping_arr)
    return customization_spec
  end

  def createRelocateSpec
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])

    relocate_spec = nil
    if resource[:cluster] and resource[:cluster].chomp.length != 0
      # incase cluster name is provided
      # Check whether the host name is provided
      if resource[:host]
        # unsetting the value of resource[:host]
        # as cluster name is provided.
        resource[:host] = ''
      end

      cluster ||= dc.find_compute_resource(resource[:cluster])

      if !cluster
        raise Puppet::Error, "Unable to find cluster '"+resource[:cluster]+"'."
      else
        relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:pool => cluster.resourcePool)

        if resource[:target_datastore] and resource[:target_datastore].chomp.length != 0
          # Incase target_datastore value is provided.
          ds ||= dc.find_datastore(resource[:target_datastore])
          if !ds
            raise Puppet::Error, "Unable to find target datastore '"+resource[:target_datastore]+"'."
            relocate_spec = nil
          else
            relocate_spec.datastore = ds
          end
        end
      end
    elsif resource[:host] and resource[:host].chomp.length != 0
      host_view = vim.searchIndex.FindByIp(:datacenter => dc , :ip => resource[:host], :vmSearch => false)

      if !host_view
        raise Puppet::Error, "Unable to find host '"+resource[:host]+"'."
      else
        if resource[:diskformat].eql?('thin')
          diskFormat = "sparse"
        elsif resource[:diskformat].eql?('thick')
          diskFormat = "flat"
        else
          diskFormat = "sparse"
        end

        transform = RbVmomi::VIM.VirtualMachineRelocateTransformation(diskFormat);
        relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(:host => host_view,
        :pool => host_view.parent.resourcePool,
        :transform => transform)

        if resource[:target_datastore] and resource[:target_datastore].chomp.length != 0
          ds ||= dc.find_datastore(resource[:target_datastore])
          if !ds
            raise Puppet::Error, "Unable to find target datastore '"+resource[:target_datastore]+"'."
            relocate_spec = nil
          else
            relocate_spec.datastore = ds
          end
        end
      end
    else
      # Neither host not cluster name is provided. Getting the relocate specification
      # from VM view
      relocate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec
    end

    return relocate_spec
  end

  def destroy
    dc = vim.serviceInstance.find_datacenter(resource[:datacenter])

    if dc
      virtualMachineObj = nil
      if resource[:name]
        virtualMachineObj = dc.find_vm(resource[:name]) or abort "VM not found"
      elsif resource[:path]
        virtualMachineObj  = dc.find_vm(resource[:path]) or abort "VM not found"
      end

      if virtualMachineObj
        vmPowerState = virtualMachineObj.runtime.powerState
        if vmPowerState.eql?('poweredOff')
          puts "VM is already powered off."
        elsif vmPowerState.eql?('poweredOn')
          puts "VM is powered on.Need to power it off."
          virtualMachineObj.PowerOffVM_Task.wait_for_completion
        elsif vmPowerState.eql?('suspended')
          puts "VM is suspended."
        end
      end
    end
    virtualMachineObj.Destroy_Task.wait_for_completion
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
    rescue Exception => e
      puts e.message
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

    rescue Exception => e
      flag = 1
      puts "Unable to perform the operation because the following exception occurred."
      puts e.message
    end
  end

  private

  def vm
    begin
      dc = vim.serviceInstance.find_datacenter(resource[:datacenter])
      @vmObj ||= dc.find_vm(resource[:name])
    rescue Exception => e
      raise Puppet::Error, e.message
    end
  end
end
