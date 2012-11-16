require 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_global_config) do
  @doc = "Manage vShield global config."

  newparam(:host, :namevar => true) do
    desc "vShield hostname or ip address."
  end

  newproperty(:vc_info, :parent => Puppet::Property::VMware_Hash) do
  end

  newproperty(:host_info, :parent => Puppet::Property::VMware_Hash) do
  end

  newproperty(:dns_info, :parent => Puppet::Property::VMware_Hash) do
  end

  newproperty(:time_info, :parent => Puppet::Property::VMware_Hash) do
  end
end
