provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'resolv'

Puppet::Type.type(:vc_vm_pci_passthru).provide(:vc_vm_pci_passthru, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages ESXi VM PCI Pass-Thru configuration."

  def exists?
    @vm_pci_device = nil
    if host_pci_device
      @vm_pci_device = vm.config.hardware.device.grep(RbVmomi::VIM::VirtualPCIPassthrough).find { |vm_device| vm_device.backing.id == @host_pci_device.id }
    end

   !@host_pci_device.nil? && !@vm_pci_device.nil? && @host_pci_device.id == @vm_pci_device.backing.id
  end

  def create
    Puppet.debug("Inside create block")
    # Possible scenarios:
    # 1. VM do not have PCI device configuration
    # 2. VM have different PCI device configuration

    # Trying #2
    pci_device = find_vm_host.hardware.pciDevice.find { |pci_dev| pci_dev.id ==  host_pci_device.id }
    pci_id = pci_device.id
    pci_device_id = pci_device.deviceId.to_s(16)
    vendor_id = pci_device.vendorId
    host_uuid = find_vm_host.esxcli.system.uuid.get

    backing = RbVmomi::VIM.VirtualPCIPassthroughDeviceBackingInfo(
      :id => pci_id,
      :deviceId => pci_device_id,
      :vendorId => vendor_id,
      :systemId => host_uuid,
      :deviceName => ""
    )

    if vm_pci_device.nil?
      Puppet.debug("VM PCI Device configuration is missing")
      update_power_state("poweredOff".to_sym)

      pciDevice = RbVmomi::VIM.send(:VirtualPCIPassthrough, :backing => backing, :key => 0)
      pci_passthru_device_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(
        :device => pciDevice,
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
      )
      spec = RbVmomi::VIM.VirtualMachineConfigSpec(:deviceChange => [pci_passthru_device_spec])
      Puppet.debug("Adding VM PCI Device Spec #{spec}")
      vm.ReconfigVM_Task(:spec => spec)

      Puppet.debug("Initiating VM power-on operation")
      update_power_state("poweredOn".to_sym)
    elsif host_pci_device.id != vm_pci_device.backing.id
      Puppet.debug("VM PCI Device configuration is not matching with VM PCI Device configuration")
      update_power_state("poweredOff".to_sym)

      pciDevice = RbVmomi::VIM.send(:VirtualPCIPassthrough, :backing => backing, :key => 0)

      # Remove stale PCI device configuration
      Puppet.debug("Removing VM PCI device configuration")
      pci_passthru_device_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(
        :device => vm_pci_device,
        :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('remove')
      )
      spec = RbVmomi::VIM.VirtualMachineConfigSpec(:deviceChange => [pci_passthru_device_spec])
      Puppet.debug("VM PCI Device Remove SPEC #{spec}")
      vm.ReconfigVM_Task(:spec => spec)

      # Add new PCI device configuraion
      Puppet.debug("Adding new VM PCI device")
      pci_passthru_device_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(
          :device => pciDevice,
          :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation('add')
      )
      spec = RbVmomi::VIM.VirtualMachineConfigSpec(:deviceChange => [pci_passthru_device_spec])
      Puppet.debug("Adding VM PCI Device Spec #{spec}")
      vm.ReconfigVM_Task(:spec => spec)

      Puppet.debug("Initiating VM power-on operation")
      update_power_state("poweredOn".to_sym)
    end
  end

  def destroy
    Puppet.debug("Inside destroy block")
  end

  def host_pci_device
    @host_pci_device ||= find_vm_host.config.pciPassthruInfo.find { |pci| pci.passthruActive == true }
  end

  def vm_pci_device
    @vm_pci_device ||= vm.config.hardware.device.grep(RbVmomi::VIM::VirtualPCIPassthrough).find { |vm_device| vm_device.backing.id == host_pci_device.id }
  end

  def host
    @host ||= vim.searchIndex.FindByDnsName(:datacenter => datacenter , :dnsName => resource[:host], :vmSearch => false) or raise(Puppet::Error, "Unable to find the host '#{resource[:host]}")
  end

  def datacenter
    @datacenter ||= vim.serviceInstance.find_datacenter(resource[:datacenter]) or raise(Puppet::Error, "datacenter '#{resource[:datacenter]}' not found.")
  end

  def vm
    @vm ||= datacenter.vmFolder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find {|v| v.name == resource[:name]}
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

