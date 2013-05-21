# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_dnsconfig) do
  @doc = "This resource allows disabling dhcp for DNS, and setting DNS client parameters"

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:address, :array_matching => :all) do
    desc "dns server address"
    defaultto([])
  end

  newproperty(:dhcp) do
    desc "boolean for dns config from dhcp"
    validate do |value|
      fail("dhcp value cannot be #{value}.  This resource only allows disabling dhcp.") unless
        value == false
    end
    newvalues(:true, :false)
  end

  newproperty(:host_name) do
    desc "server hostname"
  end

  newproperty(:domain_name) do
    desc "dns suffix"
  end

  newproperty(:search_domain, :array_matching => :all) do
    desc "dns search domain"
    defaultto([])
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
