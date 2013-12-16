# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vm_snapshot) do
  @doc = "Manage vCenter VMs Snapshot Operation."

  newparam(:name, :namevar => true) do
    desc "Name of the snapshot."
	validate do |value|
		if value.strip.length == 0
		    raise ArgumentError, "%s is invalid snapshot name." % value
		end
	end
  end
  
  newparam(:memory_snapshot) do 
    desc "Memory dump of the snapshot."
	newvalues(:true, :false)
	defaultto(:true)
 end
 
 newparam(:snapshot_supress_power_on) do 
    desc "Name of the vm."
	newvalues(:true, :false)
	defaultto(:true)
 end

  newparam(:vm_name) do 
    desc "Name of the vm."
	validate do |value|
    if value.strip.length == 0
		    raise ArgumentError, "%s is invalid vm name." % value
		end
	end
  end
  
  newproperty (:snapshot_operation)do
    desc "Operation to remove or revert the snapshot."
    newvalues(:revert, :remove, :create)
  end

  newparam(:datacenter) do 
    desc "Name of the datacenter."
	validate do |value|
    if value.strip.length == 0
		    raise ArgumentError, "%s is invalid datacenter name." % value
		end
	end
  end

end

