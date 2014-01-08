Puppet::Type.newtype(:vc_migratevm) do
  @doc = "Migrate vCenter VMs."

  newproperty(:migratevm_host) do
    desc "Migrates a VMware Virtual Machine host to another host."
    munge do |value|
      value.to_s
    end
  end

  newproperty(:migratevm_datastore) do
    desc "Migrates a VMware Virtual Machine's storage to another datastore."
    munge do |value|
      value.to_s
    end
  end

  newproperty(:migratevm_host_datastore) do
    desc "Migrates a VMware Virtual Machine host to another host and moves its storage to another datastore."
    validate do |value|
      if value.split(",").first.strip.length == 0
        raise ArgumentError, "A valid format for specifying the argument is '<target_host>,<target_datastore>'."
      end
      if value.split(",").last.strip.length == 0
        raise ArgumentError, "A valid format for specifying the argument is '<target_host>,<target_datastore>'."
      end
    end
    munge do |value|
      value.to_s
    end
  end

  newparam(:name, :namevar => true) do
    desc "The virtual machine name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid virtual machine name."
      end
    end
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter name."
      end
    end
  end

  newparam(:disk_format) do
    desc "Type of virtual disk format"
    newvalues(:thin, :thick , :same_as_source)
    defaultto(:same_as_source)
    munge do |value|
      if value.eql?('thin')
        "sparse"
      elsif value.eql?('thick')
        "flat"
      else
        value.to_s
      end
    end
  end
end