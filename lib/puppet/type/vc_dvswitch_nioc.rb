# Copyright (C) 2013 VMware, Inc.

require 'pathname' # WORK_AROUND #14073 and #7788
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'

Puppet::Type.newtype(:vc_dvswitch_nioc) do
  @doc = "Manages vCenter Distributed Virtual Switch "\
         "Network Resource Management (NIOC)"

  newparam(:name, :namevar => true) do
    desc "{path to dvswitch}{:optional tag to make resource name unique}"
    munge do |value|
      @resource[:path], ignore = value.split(':',2)
      value
    end
  end

  newparam(:path) do
    desc "The path to the dvswitch."
    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
  end

  newproperty(:network_resource_management_enabled) do
    desc "Enable or disable NIOC (network resource management); true/false"
    newvalues(:true, :false)
  end

  # autorequire switch
  autorequire(:vc_dvswitch) do
    Pathname.new(self[:name]).to_s
  end

end
