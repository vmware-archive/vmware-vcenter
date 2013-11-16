# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:vc_dvswitch_pool) do
  @doc = "Manages vCenter Distributed Virtual Switch "\
         "Network Resource Pool Management"

  newparam(:name, :namevar => true) do
    desc "{path to dvswitch}:{network resource pool key}"

    munge do |value|
      @resource[:dvswitch_path], @resource[:key] = value.split(':',2)
      value
    end
  end

  newparam(:dvswitch_path) do
    desc "The path to the dvportgroup."
    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
    munge do |value|
      @resource[:dvswitch_name] = value.split('/')[-1]
      value
    end
  end

  newparam(:dvswitch_name) do
  end

  newproperty(:key) do
    desc "pool identifier"
  end

  newproperty(:limit) do
    desc ""
  end

  newproperty(:priority_tag) do
    desc "QOS priority tag"
  end

  newproperty(:shares) do
    desc "network shares"
  end

  newproperty(:level) do
    desc "Share level ('custom', 'high', 'low', 'normal')"
    newvalues(:custom, :high, :low, :normal)
  end

  # autorequire datacenter
  autorequire(:vc_dvswitch) do
    self[:dvswitch_path]
  end

end
