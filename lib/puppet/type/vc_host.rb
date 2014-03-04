# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_host) do
  @doc = "Manage vCenter hosts."

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
    desc "ESX hostname or ip address."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid hostname or IP."
      end
    end
  end

  newparam(:username) do
    desc "ESX username."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid username."
      end
    end
  end

  newparam(:password) do
    desc "ESX password."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid password."
      end
    end
  end

  newparam(:sslthumbprint) do
    desc "ESX host ssl thumbprint."
  end

  newparam(:secure) do
    desc "Add host require sslthumprint verification."

    newvalues(:true, :false)
    defaultto(false)
  end

  newproperty(:path) do
    desc "The path to the host."

    validate do |path|
      raise ArgumentError, "Absolute path of the host is required: #{path}" unless Puppet::Util.absolute_path?(path)
    end
  end

  autorequire(:vc_datacenter) do
    # autorequire immediate parent Datacenter
    self[:path]
  end

  autorequire(:vc_folder) do
    # autorequire immediate parent Folder.
    self[:path]
  end

  autorequire(:vc_cluster) do
    # autorequire immediate parent Cluster.
    self[:path]
  end

  autorequire(:anchor) do
    # autorequire optional anchor to wait for vc_cluster config
    self[:path]
  end
end
