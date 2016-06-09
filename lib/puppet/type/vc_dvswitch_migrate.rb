# Copyright (C) 2013 VMware, Inc.

require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent

require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

Puppet::Type.newtype(:vc_dvswitch_migrate) do
  @doc = "Manages Distributed Virtual Switch migration on an ESXi host"\
         "by moving vmknics and vmnics from standard to distributed switch"

  newparam(:name, :namevar => true) do
    desc "{name of host}:{path of dvswitch}[:{optional tag}"

    munge do |value|
      @resource[:host], @resource[:dvswitch], tag = value.split(':',3)
      value
    end
  end

  newparam(:host) do
    desc "Name of ESXi host, as known to vCenter"
  end

  newparam(:dvswitch) do
    desc "Path of the destination distributed virtual switch"
  end

  newproperty(:vmk0) do
    desc "For kernel port vmk0, name of the destination dvportgroup"
  end
  newproperty(:vmk1) do
    desc "For kernel port vmk1, name of the destination dvportgroup"
  end
  newproperty(:vmk2) do
    desc "For kernel port vmk2, name of the destination dvportgroup"
  end
  newproperty(:vmk3) do
    desc "For kernel port vmk3, name of the destination dvportgroup"
  end

  newproperty(:vmnic0) do
    desc "For uplink port vmnic0, name of the destination dvportgroup"
  end
  newproperty(:vmnic1) do
    desc "For uplink port vmnic1, name of the destination dvportgroup"
  end
  newproperty(:vmnic2) do
    desc "For uplink port vmnic2, name of the destination dvportgroup"
  end
  newproperty(:vmnic3) do
    desc "For uplink port vmnic3, name of the destination dvportgroup"
  end

end
