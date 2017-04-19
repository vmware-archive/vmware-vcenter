# Copyright (C) 2013 VMware, Inc.
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:esx_reconfigureha) do
  @doc = "Rescan all HBA"

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
    desc "ESX host name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "An invalid host name or IP address is entered. Enter the correct host name and IP address."
      end
    end
  end

  newparam(:path) do
    desc "Datacenter path where host resides"
    validate do |path|
      raise ArgumentError, "Absolute path is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:force, :boolean => true, :parent => Puppet::Parameter::Boolean)

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:host]
  end
end

