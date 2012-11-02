Puppet::Type.newtype(:vc_vm) do
  @doc = "Manage vCenter VMs."

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
    desc "The vm name"
  end

  newparam(:path) do
    desc "The path to the Datacenter."

    validate do |path|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
    end
  end

  newparam(:cpucount) do
  end

  newparam(:memory) do
  end

  newparam(:guestid) do
  end

  newparam(:datastore) do
  end

  autorequire(:vc_folder) do
    Pathname.new(self[:path]).parent.to_s
  end
end
