require 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_dns) do
  @doc = 'Manage vShield dns service'

  newparam(:scope_name, :namevar => true) do
    desc 'name of the vshield edge to enabled the dns service on'
  end

  newproperty(:dns_servers, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'these are the dns servers which vshield points to'
    defaultto([])
  end

  newproperty(:enabled) do
    desc 'whether or not this service should be enabled'
    newvalues(:false, :true)
    defaultto(:false)
  end

  newparam(:scope_type) do
    desc 'scope type, this can be either datacenter or edge'
    newvalues(:edge)
    defaultto(:edge)
  end

  autorequire(:vshield_edge) do
    self[:name]
  end

end
