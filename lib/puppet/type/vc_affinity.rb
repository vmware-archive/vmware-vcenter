# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_affinity) do
  @doc = "Manage vCenter Cluster affinity rules."

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
    desc "Name of the cluster rule"
  end

  newparam(:vm) do
    desc "Array of virtual machines"
  end

  newparam(:rule_type) do
    desc "Type of rule: affinity or anti_affinity"

    newvalues(:affinity, :anti_affinity)
  end

  newparam(:path) do
    desc "The path to the Cluster."

    validate do |path|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

  # autorequire immediate parent path (can be datacenter or folder)
  autorequire(:vc_folder) do
    Pathname.new(self[:path]).parent.to_s
  end

  autorequire(:vc_datacenter) do
    Pathname.new(self[:path]).parent.to_s
  end
end

