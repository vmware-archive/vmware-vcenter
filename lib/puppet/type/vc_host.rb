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

  newparam(:name) do
    desc "Host name (usually the ip address)."
    isnamevar
  end

  newparam(:username) do
    desc "Name of the user on the host."
  end

  newparam(:password) do
    desc "Password of the user on the host."
  end

  newparam(:connection) do
    desc "The connectivity to vCenter."
    # username:password@vcenter_host
  end

  newproperty(:path) do
    desc "The path to the host.  Used when the host is created or moved."
  end

  autorequire(:vc_datacenter) do
    # autorequire immediate parent Datacenter
    self[:path]
  end

  autorequire(:vc_folder) do
    # autorequrie immediate parent Folder.
    self[:path]
  end

  autorequire(:vc_cluster) do
    # autorequrie immediate parent Cluster.
    self[:path]
  end
end

