# Copyright (C) 2013 VMware, Inc.
require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
require File.join vmware_module.path, 'lib/puppet/property/vmware'

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

  newparam(:lag) do
    desc "lacp lag for uplink"
  end

  ('0'..'16').each do |i|
    vmk_port = 'vmk' + i
    newproperty(vmk_port.to_sym) do
      desc "For kernel port %s, name of the destination dvportgroup" % vmk_port
    end

    vmnic_port  = 'vmnic' + i
    newproperty(vmnic_port.to_sym) do
      desc "For uplink port %s, name of the destination dvportgroup" % vmnic_port
    end
  end
end
