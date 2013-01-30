require 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_firewall) do
  @doc = 'Manage vShield firewalls, these are used by fw rules'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'firewall name'
  end

  newproperty(:source, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'these are source ipset(s) / vnics that can be members of firewall rules, the default is any'
    defaultto([])
  end

  newproperty(:destination, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'these are destination ipset(s) / vnics that can be members of firewall rules, the default is any'
    defaultto([])
  end

  newproperty(:service_application, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'these are destination service(s) that are applications only, the default is any'
    defaultto([])
  end

  newproperty(:service_group, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'these are destination service(s) that are application groups only, the default is any'
    defaultto([])
  end

  newproperty(:action) do
    desc 'this is the action to take, can be either accept or deny, default is accept'
    newvalues(:accept, :deny)
    defaultto(:accept)
  end

  #newproperty(:log) do
  #  desc 'this is whether or not the rule will log, can be either true or false, default is false'
  #  newvalues(:true, :false)
  #  defaultto(:false)
  #end

  newparam(:scope_type) do
    desc 'scope type, this can be either datacenter or edge'
    newvalues(:edge, :datacenter)
  end

  newparam(:scope_name) do
    desc 'scope name which will be used with scope_type to get/set firewalls'
  end

end
