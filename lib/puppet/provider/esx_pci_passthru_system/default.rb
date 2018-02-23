# Copyright (C) 2018 Dell EMC, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_pci_passthru_system).provide(:esx_pci_passthru_system, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages Passthrough System."

  def create
    Puppet.debug "Entered in create pci passthru config method."
    begin
      pci_device_config = RbVmomi::VIM.HostPciPassthruConfig(:id => resource[:pci_device_id], :passthruEnabled => true)
      pci_passthu_system.UpdatePassthruConfig(:config => [pci_device_config])

      # sleep for 30 seconds to make sure that the configuration change is written
      sleep 30

      if !active?
        Puppet.debug "Reboot the host to activate the PCI passthrough"
        reboot_and_wait_for_host
        unless active?
          fail "Failed to enable and activate PCI passthrough on the target device with id, #{resource[:pci_device_id]}"
        end
      elsif enabled? && active?
        Puppet.debug "Target device has already been enabled and activated.. Nothing to do!"
      end

    rescue
      fail "Failed to enable PCI passthrough with following error, %s:%s" % [$!.class, $!.message]
    end
  end

  def destroy
    Puppet.debug "Entered in destroy pci passthru config method."
    begin
      pci_device_config = RbVmomi::VIM.HostPciPassthruConfig(:id => resource[:pci_device_id], :passthruEnabled => false)
      pci_passthu_system.UpdatePassthruConfig(:config => [pci_device_config])

      # sleep for 30 seconds to make sure that the configuration change is written
      sleep 30

      if active?
        Puppet.debug "Reboot the host to deactivate the PCI passthrough"
        reboot_and_wait_for_host
        unless !active?
          fail "Failed to disable and deactivate PCI passthrough on the target device with id, #{resource[:pci_device_id]}"
        end
      elsif enabled? && active?
        Puppet.debug "Target device is disabled and deactivated.. Nothing to do!"
      end

    rescue
      fail "Failed to disable PCI passthrough with following error, %s:%s" % [$!.class, $!.message]
    end
  end

  def exists?
    enabled? && active?
  end

  def enabled?
    Puppet.debug "Check if the PCI passthrough setting is enabled on the target device"
    device = pci_passthu_system.pciPassthruInfo.find { |pci| pci.id == resource[:pci_device_id] }
    !device.nil? && device.passthruEnabled == true
  end

  def active?
    Puppet.debug "Check if the PCI passthrough setting is active on the target device"
    device = pci_passthu_system.pciPassthruInfo.find { |pci| pci.id == resource[:pci_device_id] }
    !device.nil? && device.passthruActive == true
  end

  ####################################################################################################################
  ########################################## HELPER METHODS ##########################################################
  ####################################################################################################################
  def pci_passthu_system
    Puppet.debug "Getting PCI Passthrough system from esxhost, #{host.name}"
    @pci_passthru_sys ||= host.configManager.pciPassthruSystem
  end

  def reboot_and_wait_for_host
    host.RebootHost_Task({:force => false}).wait_for_completion
    wait_for_host(300, resource[:reboot_timeout])
  end
end
