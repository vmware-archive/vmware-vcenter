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
  end

  newparam(:username) do
    desc "ESX username."
  end

  newparam(:password) do
    desc "ESX password."
  end

  newparam(:sslthumbprint) do
    desc "ESX host ssl thumbprint."
  end

  newparam(:secure) do
    desc "Add host require sslthumprint verification."

    newvalues(:true, :false)
    defaultto(false)
  end

  newparam(:transport) do
    desc "The connectivity to vCenter."
  end

  newproperty(:path) do
    desc "The path to the host."

    validate do |path|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
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
end
