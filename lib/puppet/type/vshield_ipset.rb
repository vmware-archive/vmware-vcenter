require 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_ipset) do
  @doc = 'Manage vShield ipsets, these are used by fw rules'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'ipset name'
  end

  newproperty(:value, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'ipset value, this is a string that can consist of ip addresses, networks, and range of addresses seperated with commas'
  end

  newparam(:scope_type) do
    desc 'scope type, this can be either datacenter or edge'
    newvalues(:edge, :datacenter)
  end

  newparam(:scope_name) do
    desc 'scope name which will be used with scope_type to get/set ipsets'
  end

end
