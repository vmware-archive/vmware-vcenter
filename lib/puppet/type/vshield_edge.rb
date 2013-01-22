require 'pathname'
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet/property/vmware'

Puppet::Type.newtype(:vshield_edge) do
  @doc = 'Manage vShield edge.'

  newparam(:name, :namevar => true) do
    desc 'vShield manager hostname or ip address and vShield edge name seperated with : (i.e. manager:edge).'

    munge do |value|
      @resource[:manager], @resource[:edge_name] = value.split(':',2)
      value
    end
  end

  ensurable

  newparam(:manager, :parent => Puppet::Property::VMware) do
    desc 'vShield Manager, derived from namevar, do not specify.'
  end

  newparam(:edge_name, :parent => Puppet::Property::VMware) do
    desc 'vShield edge, derived from namevar, do not specify.'
  end

  newparam(:compute, :parent => Puppet::Property::VMware) do
  end

  newparam(:datastore, :parent => Puppet::Property::VMware) do
  end

  newparam(:fqdn, :parent => Puppet::Property::VMware) do
  end

  newparam(:appliance_size, :parent => Puppet::Property::VMware) do
    newvalues(:compact, :large, :XLarge)
    defaultto(:compact)
  end

  newparam(:appliance, :parent => Puppet::Property::VMware_Hash) do
  end

  newproperty(:vnics, :array_matching => :all) do
  end

  newparam(:datacenter_name, :parent => Puppet::Property::VMware) do
  end

  newproperty(:enable_aesni, :parent => Puppet::Property::VMware) do
    newvalues(:true, :false)
  end

  newproperty(:enable_fips, :parent => Puppet::Property::VMware) do
    newvalues(:true, :false)
  end

  newproperty(:enable_tcp_loose, :parent => Puppet::Property::VMware) do
    newvalues(:true, :false)
  end

  newproperty(:vse_log_level, :parent => Puppet::Property::VMware) do
    newvalues('debug', 'info', 'emergency', 'alert', 'critical', 'error', 'warning', 'notice')
  end

  newproperty(:firewall, :parent => Puppet::Property::VMware_Hash) do
    def change_to_s(is, should)
      "#{is.inspect}\n#{should.inspect}"
    end
  end

  autorequire(:transport) do
    self[:manager]
  end

  autorequire(:vshield_global_config) do
    self[:manager]
  end
end

