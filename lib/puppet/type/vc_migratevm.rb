Puppet::Type.newtype(:vc_migratevm) do
  @doc = "Migrate vCenter VMs."

  newproperty(:migratevm_host) do
    desc "Migrate VM Host."
    munge do |value|
      value.to_s
    end
  end

  newproperty(:migratevm_datastore) do
    desc "Migrate VM Datastore."
    munge do |value|
      value.to_s
    end
  end

  newproperty(:migratevm_host_datastore) do
    desc "Migrate VM Host and Datastore."
    validate do |value|
      if value.split(",").first.strip.length == 0
        raise ArgumentError, "Please specify the argument in proper format '<target_host,<target_datastore>'."
      end
      if value.split(",").end.strip.length == 0
        raise ArgumentError, "Please specify the argument in proper format '<target_host,<target_datastore>'."
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
        raise ArgumentError, "Invalid vm name."
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
    desc "Name of the target datastore."
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
