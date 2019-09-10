# Copyright (C) 2019 VMware, Inc.
require "puppet_x/vmware/util"
require "puppet_x/vmware/mapper"
require "puppet/property/vmware"

Puppet::Type.newtype(:vc_vm_rdm) do
  @doc = 'Process RDM disks'
  ensurable do
    newvalue(:add) do
      provider.add_rdm_disks
    end
    newvalue(:remove) do
      provider.remove_rdm_disks
    end
  end

  newparam(:name, :namevar => true) do
    desc 'The virtual machine name.'
    newvalues(/.+/)
  end

  newparam(:datacenter) do
    desc 'Name of the datacenter.'
    newvalues(/.+/)
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:rdm_disk_details) do
    desc 'Set the RDM Disk details.This will be a hash containing disk serial numbers as key ,and value as a hash containing disk path and disk size'
  end

end
