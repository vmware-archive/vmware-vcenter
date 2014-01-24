# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_fc_multiple_path_config) do
  @doc = "FC / FCoE Storage multi-pathing configuration (Fixed / Round-Robin)"

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
    desc "ESX host:service IP/name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "An invalid host name or IP address is entered. Enter the correct host name and IP address."
      end
    end
  end

  newproperty(:policyname) do
    desc "String representing the path selection policy for a device. Use one of the following strings:
        VMW_PSP_FIXED - Use a preferred path whenever possible.
        VMW_PSP_RR - Round Robin Load balance.
        VMW_PSP_MRU - Use the most recently used path."
    newvalues(:VMW_PSP_RR, :VMW_PSP_FIXED, :VMW_PSP_MRU)
  end

  newparam(:path) do
    desc "Datacenter path where host resides"
    validate do |path|
      raise ArgumentError, "Absolute path is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end
end