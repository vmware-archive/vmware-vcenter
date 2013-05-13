# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_datastore) do
  @doc = "Manage vCenter esx hosts service."

  feature :remote, "Manage remote CIFS/NFS filesystem."

  newparam(:name, :namevar => true) do
    desc "ESX host:service name."

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
  end

  newparam(:host) do
    desc "The ESX host the service is running on."
  end

  newproperty(:type) do
    desc "The datastore type."
    newvalues(:vmfs, :nfs, :cifs)
    defaultto(:nfs)
    munge do |value|
      value.upcase
    end
  end

  newparam(:local_path) do
  end

  newparam(:access_mode) do
    desc 'Enum - HostMountMode: Defines the access mode of the datastore.'
    newvalues('readOnly', 'readWrite')
    defaultto('readWrite')
    munge do |value|
      value.to_s
    end
  end

  # CIFS/NFS only properties.
  newproperty(:remote_host, :required_features => :remote) do
  end

  newproperty(:remote_path, :required_features => :remote) do
  end

  # CIFS only parameters.
  newparam(:user_name) do
  end

  newparam(:password) do
  end

  # VMFS only parameters
  newparam(:lun) do
    munge do |value|
      Integer(value)
    end
  end

  validate do
    if [:nfs, :cifs].include? self[:type] 
      raise Puppet::Error, "Missing remote_host property" unless self[:remote_host]
      raise Puppet::Error, "Missing remote_path property" unless self[:remote_path]
    elsif self[:type] == :vmfs
      raise Puppet::Error, "Missing lun property" unless self[:lun]
    end
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:host]
  end
end
