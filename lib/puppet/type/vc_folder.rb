# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_folder) do
  @doc = "Manage vCenter folders."

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:path, :namevar => true) do
    desc "The path to the folder."

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
