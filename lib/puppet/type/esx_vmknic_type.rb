# Copyright (C) 2013 VMware, Inc.

require 'pathname'
module_lib = Pathname.new(__FILE__).parent.parent.parent

require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet/property/vmware'

Puppet::Type.newtype(:esx_vmknic_type) do
  @doc = "Manages Virtual Adapters"

  newparam(:name, :namevar => true) do
    desc "{ESX Host}:{name of vmknic}"

    munge do |value|
      @resource[:esxi_host], @resource[:nicname] = value.split(':',2)
      value
    end
  end

  newparam(:esxi_host) do
    desc "Name of the ESXi host containing the vmknic."
  end

  newparam(:nicname) do
    desc "Name of the vmknic on the ESXi host."
  end

  newproperty(:nic_type, :parent => Puppet::Property::VMware_Array,
        :array_matching => :all, :sort => :true, :inclusive => :true
      ) do
    desc "List (array) of names of types for nic: zero or more of "\
        "vmotion, faultToleranceLogging, management, or vSphereReplication"
    newvalues(
        'faultToleranceLogging', 'management', 'vmotion', 'vSphereReplication'
      )
  end


  validate do
    self[:nic_type] = Array(self[:nic_type]).uniq.sort
  end

end
