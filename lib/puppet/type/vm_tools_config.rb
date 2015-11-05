# Copyright (C) 2014 VMware, Inc.
Puppet::Type.newtype(:vm_tools_config) do

  newparam(:name) do
    desc 'The datacenter and vm name split by a colon (:). Format dc1:vm1'

    munge do |value|
      @resource[:datacenter], @resource[:vm_name] = value.split(':',2)
    end
  end

  newparam(:vm_name) do
    desc "Set by namevar. Format datacenter:vmname"
  end

  newparam(:datacenter) do
    desc "Set by namevar. Format datacenter:vmname"
  end

  newproperty(:after_power_on) do
    desc 'Flag to specify whether or not scripts should run after the virtual machine powers on.'
    newvalues(:true, :false)
  end

  newproperty(:after_resume) do
    desc 'Flag to specify whether or not scripts should run after the virtual machine resumes.'
    newvalues(:true, :false)
  end

  newproperty(:before_guest_reboot) do 
    desc 'Flag to specify whether or not scripts should run before the virtual machine reboots.'
    newvalues(:true, :false)
  end

  newproperty(:before_guest_shutdown) do 
    desc 'Flag to specify whether or not scripts should run before the virtual machine powers off.'
    newvalues(:true, :false)
  end

  newproperty(:before_guest_standby) do
    desc 'Flag to specify whether or not scripts should run before the virtual machine suspends. '
    newvalues(:true, :false)
  end

  newproperty(:sync_time_with_host) do
    desc 'Indicates whether or not the tools program will sync time with the host time.'
    newvalues(:true, :false)
  end

  newproperty(:tools_upgrade_policy) do
    desc 'Tools upgrade policy setting for the virtual machine.'
    newvalues(:upgradeAtPowerCycle, :manual)
    munge do |value| value.to_sym end
  end
end
