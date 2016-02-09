# Copyright (C) 2016 VMware, Inc.
Puppet::Type.newtype(:vc_host_group) do
  @doc = "Manages vCenter cluster's settings for Host Groups used for VM-Host rules. http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.cluster.HostGroup.html"

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
    desc "Name of the host group"
  end

  newparam(:path) do
    desc "The path to the Cluster."

    validate do |path|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newproperty(:hosts, :array_matching => :all) do
    desc "Array of hosts"
  end

  # autorequire immediate parent path (can be datacenter or folder)
  autorequire(:vc_folder) do
    Pathname.new(self[:path]).parent.to_s
  end

  autorequire(:vc_datacenter) do
    Pathname.new(self[:path]).parent.to_s
  end
end

