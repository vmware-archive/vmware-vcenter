require 'puppet/modules/vcenter/type_base'

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
    # autorequrie immediate parent Folder.
    Puppet::Modules::VCenter::TypeBase.get_immediate_parent(self[:path])
  end

  autorequire(:vc_datacenter) do
    # autorequrie immediate parent Datacenters.
    Puppet::Modules::VCenter::TypeBase.get_immediate_parent(self[:path])
  end
end

