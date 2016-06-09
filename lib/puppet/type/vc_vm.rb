# Copyright (C) 2013 VMware, Inc.

require File.dirname(__FILE__) + "/../../puppet_x/vmware/vmware_lib/puppet/property/vmware"

Puppet::Type.newtype(:vc_vm) do
  @doc = "Manage vCenter VMs. Warning, this type / provider is currently experimental"

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

  #newparam(:path) do
  #  desc "The path to the Datacenter."
  #
  #  validate do |path|
  #    raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(path)
  #  end
  #end

  newparam(:cpucount) do
  end

  newparam(:memory) do
  end

  newparam(:guestid) do
  end

  newparam(:datastore) do
  end

  newparam(:graceful_shutdown) do
    desc 'Perform a graceful shutdown if possible.  This parameter has no effect unless :power_state is set to :poweredOff'
    newvalues(:true,:false)
    defaultto(:true)
  end

  newproperty(:power_state) do
    desc 'set the powerstate for the vm to either poweredOn/poweredOff, for poweredOff, if tools is running a shutdownGuest will be issued, otherwise powerOffVM_TASK'
    newvalues(:poweredOn,:poweredOff)
  end

  newparam(:datacenter_name) do
    newvalues(/\w/)
  end

  #autorequire(:vc_folder) do
  #  Pathname.new(self[:path]).parent.to_s
  #end
end
