require 'pathname'
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_application) do
  @doc = 'Manage vShield applications, these are used by fw rules'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'application name'
  end

  newproperty(:value, :array_matching => :all, :parent => Puppet::Property::VMware_Array ) do
    desc 'application value, this is a string that can consist of port number(s) and ranges of ports'
  end

  newproperty(:application_protocol) do
    desc 'application protocol, example TCP/UDP/ICMP/IGMP/FTP/etc ( way to many to list, refer to api guide for more available options'
    munge do |value|
      value.upcase
    end
  end

  newparam(:scope_type) do
    desc 'scope type, this can be either datacenter or edge'
    newvalues(:edge, :datacenter)
  end

  newparam(:scope_name) do
    desc 'scope name which will be used with scope_type to get/set applications'
  end

end
