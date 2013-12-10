# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_storagepod) do

  @doc = "Manage Storage Pods (clusters)"

  newparam(:cluster, :namevar => true) do
    desc "Name of the cluster to be used"
  end

  newparam(:datacenter) do
    desc "Datacenter in which the cluster will be used"
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newproperty(:datastores, :array_matching => :all) do
    desc "Datastores to be added to Storage Pod"
    defaultto([])
  end

end
