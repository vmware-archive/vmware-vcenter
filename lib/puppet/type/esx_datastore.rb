Puppet::Type.newtype(:esx_datastore) do
  @doc = "Manage vCenter esx hosts service."

  feature :remote, "Manage remote CIFS/NFS filesystem."

  newparam(:name, :namevar => true) do
    desc "ESX host:service name."

    munge do |value|
      @resource[:host], @resource[:datastore] = value.split(':',2)
      # TODO: not sure if this is good assumption.
      @resource[:localpath] = @resource[:datastore]
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

  newparam(:localPath) do
  end

  newparam(:accessMode) do
    desc 'Enum - HostMountMode: Defines the access mode of the datastore.'
    newvalues('readOnly', 'readWrite')
    defaultto('readWrite')
    munge do |value|
      value.to_s
    end
  end

  # CIFS/NFS only properties.
  newproperty(:remoteHost, :required_features => :remote) do
  end

  newproperty(:remotePath, :required_features => :remote) do
  end

  # CIFS only parameters.
  newparam(:userName) do
  end

  newparam(:password) do
  end

  validate do
    raise Puppet::Error, "Missing remoteHost property" unless self[:remotehost]
    raise Puppet::Error, "Missing remotePath property" unless self[:remotepath]
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
