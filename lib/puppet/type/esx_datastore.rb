# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_datastore) do
  @doc = "Manage vCenter esx hosts' datastore."

  newparam(:name, :namevar => true) do
    desc "ESX host:datastore name."

    munge do |value|
      @resource[:host], @resource[:datastore] = value.split(':',2)
      # TODO: not sure if this is good assumption.
      @resource[:local_path] = @resource[:datastore]
      value
    end
  end

  ensurable

  newparam(:datastore) do
    desc "The name of the datastore."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name of the datastore."
      end
    end
  end

  newparam(:host) do
    desc "The ESX host the datastore is attached to."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid name or IP of the host."
      end
    end
  end

  newproperty(:type) do
    desc "The datastore type."
    isrequired
    newvalues(:nfs, :cifs, :vmfs)
    munge do |value|
      value.upcase
    end
  end

  newparam(:local_path) do
  end

  newparam(:access_mode) do
    desc "Enum - HostMountMode: Defines the access mode of the datastore."
    newvalues("readOnly", "readWrite")
    defaultto("readWrite")
    munge do |value|
      value.to_s
    end
  end

  # CIFS/NFS only properties.
  newproperty(:remote_host) do
    desc "Name or IP of remote storage host.  Specify only for file based storage."
  end

  newproperty(:remote_path) do
    desc "Path to volume on remote storage host.  Specify only for file based storage."
  end

  # CIFS only parameters.
  newparam(:user_name) do
  end

  newparam(:password) do
  end

  # VMFS only parameters
  newparam(:lun) do
    desc "LUN number of storage volume.  Specify only for block storage."
    munge do |value|
      Integer(value)
    end
  end

  # Not implemented
  newparam(:uid) do
  end

  newparam(:target_iqn) do
    desc "Target IQN of lun created on storage."
  end

  newparam(:path) do
    desc "Datacenter path where host resides"
  end

  validate do
    raise Puppet::Error, "Must supply a value for type" if self[:type].nil?
    if ["NFS", "CIFS"].include? self[:type]
      raise Puppet::Error, "Missing remote_host property" unless self[:remote_host]
      raise Puppet::Error, "Missing remote_path property" unless self[:remote_path]
      raise Puppet::Error, "lun property should only be included if type is 'vmfs'" if self[:lun]
    elsif self[:type] == "VMFS"
      raise Puppet::Error, "Missing lun or target_iqn property" unless self[:lun] or self[:target_iqn]
      raise Puppet::Error, "remote_host property should only be included if type is 'nfs' or 'cifs'" if self[:remote_host]
      raise Puppet::Error, "remote_path property should only be included if type is 'nfs' or 'cifs'" if self[:remote_path]
    end
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:host]
  end
end
