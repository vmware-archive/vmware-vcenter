# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_fcoe) do
  @doc = "Add/Remove FCoE software adapters in vCenter hosts."

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc "ESX host:Name of the underlying physical Nic that will be associated with the FCoE HBA."
    munge do |value|
      @resource[:host], @resource[:physical_nic] = value.split(':',2)
      value
    end
  end

  newparam(:physical_nic) do
    desc "Name of the underlying physical Nic that will be associated with the FCoE HBA."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid underlying physical nic."
      end
    end
  end

  newparam(:host) do
    desc "Name or IP address of the host."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name or IP address of the host."
      end
    end
  end

  newparam(:path) do
    desc "Datacenter path where host resides"
    validate do |path|
      raise ArgumentError, "Absolute path is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end

end
