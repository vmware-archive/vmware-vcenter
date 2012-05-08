Puppet::Type.newtype(:vc_cluster) do
  @doc = "Manage vCenter Clusters."

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:path) do
    desc "The path to the Cluster."
    isnamevar
  end

  newparam(:connection) do
    desc "The connectivity to vCenter."
    # username:password@hostname
  end

  autorequire(:vc_folder) do
    # autorequrie parent Folder.
  end

  autorequire(:vc_datacenter) do
    # autorequrie parent Datacenters.
  end
end

