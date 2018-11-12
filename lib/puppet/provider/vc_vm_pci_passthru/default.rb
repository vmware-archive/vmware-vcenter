provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'resolv'

Puppet::Type.type(:vc_vm_pci_passthru).provide(:vc_vm_pci_passthru, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages ESXi VM PCI Pass-Thru configuration."

  def exists?
   !host_pci_devices.empty? && !vm_pci_device.nil?
  end

  def create
    Puppet.debug("Inside create block")
    # Possible scenarios:
    # 1. VM do not have PCI device configuration
    # 2. VM have different PCI device configuration
    # 3. VM have a correct PCI device configuration but stale PCI device configuration(s) also exist

    Puppet.debug("Checking existing VM PCI device configurations...")
    stale_vm_pci_devices = []
    vm_pci_devices.each do |vm_pci_dev|
      stale_vm_pci_devices << vm_pci_dev unless host_pci_device_ids.include? vm_pci_dev.backing.id
    end

    Puppet.debug("There exist one or more VM PCI Device configurations, which does not match with host PCI Device configuration. They will be removed") unless stale_vm_pci_devices.empty?
    device_change = []
    stale_vm_pci_devices.each do |stale_vm_pci_dev|
      pci_passthru_device_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(
          :device => stale_vm_pci_dev,
          :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('remove')
      )
      device_change << pci_passthru_device_spec
    end

    # find an active pci passthru device on host, which is not yet configured on VM
    vm_pci_device_ids = vm_pci_devices.map {|host_pci_dev| host_pci_dev.backing.id }
    pci_device = find_vm_host.hardware.pciDevice.find { |pci_dev| !vm_pci_device_ids.include?(pci_dev.id) && host_pci_device_ids.include?(pci_dev.id) }

    if pci_device
      pci_id = pci_device.id
      pci_device_id = pci_device.deviceId.to_s(16)
      vendor_id = pci_device.vendorId
      host_uuid = find_vm_host.esxcli.system.uuid.get

      Puppet.debug("VM PCI Device configuration is missing for device with id, %s." % pci_id)
      backing = RbVmomi::VIM.VirtualPCIPassthroughDeviceBackingInfo(
        :id => pci_id,
        :deviceId => pci_device_id,
        :vendorId => vendor_id,
        :systemId => host_uuid,
        :deviceName => ""
      )

      pciDevice = RbVmomi::VIM.send(:VirtualPCIPassthrough, :backing => backing, :key => 0)
      new_pci_passthru_device_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(
        :device => pciDevice,
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
      )
      device_change << new_pci_passthru_device_spec
    end

    unless device_change.empty?
      update_power_state("poweredOff".to_sym)
      spec = RbVmomi::VIM.VirtualMachineConfigSpec(:deviceChange => device_change)
      Puppet.debug("Modifying VM PCI Device Spec #{spec}")
      vm.ReconfigVM_Task(:spec => spec)

      Puppet.debug("Initiating VM power-on operation")
      update_power_state("poweredOn".to_sym)
    end
  end

  def destroy
    Puppet.debug("Inside destroy block")
  end

  def host_pci_devices
    @__host_pci_devices ||= find_vm_host.config.pciPassthruInfo.select { |pci| pci.passthruActive == true }
  end

  def host_pci_device_ids
    host_pci_devices.map {|host_pci_dev| host_pci_dev.id }
  end

  def vm_pci_devices
    @__vm_pci_devices ||= vm.config.hardware.device.grep(RbVmomi::VIM::VirtualPCIPassthrough)
  end

  def vm_pci_device
    @__vm_pci_device ||= begin
      vm_pci_devices.find { |vm_device| host_pci_device_ids.include? vm_device.backing.id }
    end
  end

  def host
    @__host ||= vim.searchIndex.FindByDnsName(:datacenter => datacenter , :dnsName => resource[:host], :vmSearch => false) or raise(Puppet::Error, "Unable to find the host '#{resource[:host]}")
  end

  def datacenter
    @__datacenter ||= vim.serviceInstance.find_datacenter(resource[:datacenter]) or raise(Puppet::Error, "datacenter '#{resource[:datacenter]}' not found.")
  end

  def findvm(folder, vm_name)
    folder.children.each do |f|
      case f
        when RbVmomi::VIM::Folder
          foundvm = findvm(f, vm_name)
          return foundvm if foundvm
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

  def vm
    @__vm ||= findvm(datacenter.vmFolder, resource[:name])
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

  def vm_power_state
    Puppet.debug 'Retrieving the power state of the virtual machine.'
    vm.runtime.powerState
  end

  # Set the power state.
  def update_power_state(value)
    Puppet.debug 'Setting the power state of the virtual machine.'

    case value
    when :poweredOff
      vm.PowerOffVM_Task.wait_for_completion unless vm_power_state == 'poweredOff'
    when :poweredOn
      vm.PowerOnVM_Task.wait_for_completion
    when :suspended
      if @power_state == 'poweredOn'
        vm.SuspendVM_Task.wait_for_completion
      else
        raise(Puppet::Error, 'Unable to suspend the virtual machine unless in powered on state.')
      end
    when :reset
      if vm_power_state !~ /poweredOff|suspended/i
        vm.ResetVM_Task.wait_for_completion
      else
        raise(Puppet::Error, "Unable to reset the virtual machine because the system is in #{@power_state} state.")
      end
    end
  end
end
