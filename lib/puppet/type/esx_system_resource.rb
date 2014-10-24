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
    desc "CPU limit in MHz"
    newvalues(/\d{1,}/)
  end

  newparam(:cpu_unlimited) do
    desc "Enable unlimited CPU resources"
    newvalues(:true,:false)
    munge do |value|
      if value == 'true'
        @resource[:cpu_limit] = -1
      elsif value == 'false' && !(@resource[:cpu_limit])
        @resource[:cpu_limit] = 0
      end
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
    desc "Memory limit in MB"
    newvalues(/\d{1,}/)
  end

   newparam(:memory_unlimited) do
     desc "Enable unlimited Memory resources"
     newvalues(:true,:false)
     munge do |value|
       if value == 'true'
         @resource[:memory_limit] = -1
       elsif value == 'false' && !(@resource[:memory_limit])
         @resource[:memory_limit] = 0
       end
     end
   end
end
