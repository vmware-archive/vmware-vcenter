require 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_syslog) do
  @doc = "Manage vShield syslog config."

  newparam(:host, :namevar => true) do
    desc "vShield hostname or ip address."
  end

  newproperty(:server_info, :parent => Puppet::Property::VMware) do
  end

  autorequire(:transport) do
    self[:host]
  end
end
