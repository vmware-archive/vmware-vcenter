# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_system_resource) do
  @doc = "This resource allows the configuration of system resources of a host that are viewed und er the 'System Resource Allocation' section of the vSphere client"

  newparam(:name) do
    desc "A unique name that will allow for setting the same resource on multiple hosts or multiple resources on the same host through multiple resource calls within your puppet manifest."
  end

  newparam(:host,) do
    desc "ESX hostname or ip address."
  end

  newparam(:system_resource) do
    desc "The system resource to be managed"
  end

  newproperty(:cpu_reservation) do
    desc "System resource CPU reservation in MHz"
    newvalues(/\d{1,}/)
  end

  newproperty(:cpu_expandable_reservation) do
    desc "Enable expandable reservation"
    newvalues(:true, :false)
  end

  newproperty(:cpu_limit) do
    desc <<-EOT
    Sets the CPU limit.  Acceptable values are a numeric value (in Mhz) or
    the string "unlimited"
    EOT
    newvalues(/\d{1,}/, "unlimited")
    munge do |value|
      value = -1 if value == "unlimited"
      value
    end
  end

  newproperty(:memory_reservation) do
    desc "System resource memory reservation in MB"
    newvalues(/\d{1,}/)
  end
 
  newproperty(:memory_expandable_reservation) do
    desc "Enable expandable reservation"
    newvalues(:true, :false)
  end
 
  newproperty(:memory_limit) do
    desc <<-EOT
    Sets the memory limit.  Acceptable values are a numeric value (in MB) or
    the string "unlimited"
    EOT
    newvalues(/\d{1,}/, "unlimited")
    munge do |value|
      value = -1 if value == "unlimited"
      value
    end
  end

end
