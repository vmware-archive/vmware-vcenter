# Copyright (C) 2018 Dell EMC, Inc.
Puppet::Type.newtype(:esx_pci_passthru_system) do
  @doc = "Enables or disables PCI passthru on an ESX host."

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
    defaultto(:present)
  end

  newparam(:host, :namevar => true) do
    desc "The Host IP/hostname."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid host name."
      end
    end
  end

  newparam(:pci_device_id) do
    desc "The id of target PCI device."
    validate do |value|
      if value.strip.length == 0 && !resource[:auto_config]
        raise ArgumentError, "Invalid PCI device name."
      end
    end
  end

  newparam(:reboot_timeout) do
    desc "Timeout value for host reboot event."
  end

  autorequire(:vc_host) do
    self[:host]
  end
end
