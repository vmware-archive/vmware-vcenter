# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_datacenter) do
  @doc = "Manage vCenter Datacenters."

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
    desc "The path to the Datacenter."

    validate do |path|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

  autorequire(:vc_folder) do
    Pathname.new(self[:path]).parent.to_s
  end
end
