# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vm_snapshot) do
  @doc = "Manage vCenter VMs Snapshot Operation."

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
    desc "Name of the snapshot."
	validate do |value|
		unless value =~ /^\w+\s*\w+$/
		    raise ArgumentError, "%s is invalid snapshot name." % value
		end
	end
  end

  newparam(:vm_name) do 
    desc "Name of the vm."
	validate do |value|
		unless value =~ /^\w+\s*\w+$/
		    raise ArgumentError, "%s is invalid vm name." % value
		end
	end
  end
  
  newproperty (:snapshot_operation)do
    desc "Operation to remove or revert the snapshot."
    newvalues(:revert, :remove)
  end

  newparam(:datacenter) do 
    desc "Name of the datacenter."
	validate do |value|
		unless value =~ /^\w+\s*\w+$/
		    raise ArgumentError, "%s is invalid datacenter name." % value
		end
	end
  end

end

