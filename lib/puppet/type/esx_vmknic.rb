# Copyright (C) 2013 VMware, Inc.
require 'pathname'
module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet/property/vmware'


Puppet::Type.newtype(:esx_vmknic) do
  @doc = "Manages Virtual Adapters"

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
    def change_to_s(is, should)
      if should == :present
        provider.create_message
      else
        "removed"
      end
    end
  end
  
  newparam(:name, :namevar => true) do
    desc "{ESX Host}:{name of vmknic}"

    munge do |value|
      @resource[:esxi_host], @resource[:nicname] = value.split(':',2)
      value
    end
  end

  newparam(:esxi_host) do
    desc "Name of the ESXi host containing the vmknic."
  end

  newparam(:nicname) do
    desc "Name of the vmknic on the ESXi host."
  end

  newparam(:portgroup) do
    desc "Used only in creation of a new vmknic attached to a standard vswitch"
  end

  map = PuppetX::VMware::Mapper.new_map('HostVirtualNicSpecMap')
  map.leaf_list.each do |leaf|
    option = {}
    if type_hash = leaf.olio[t = Puppet::Property::VMware_Array]
      option.update(
        :array_matching => :all,
        :parent => t
      )
    elsif type_hash = leaf.olio[t = Puppet::Property::VMware_Array_Hash]
      option.update(
        # :array_matching => :all,
        :parent => t
      )
    elsif type_hash = leaf.olio[t = Puppet::Property::VMware_Array_VIM_Object]
      option.update(
        # :array_matching => :all,
        :parent => t
      )
    end
    option.update(type_hash[:property_option]) if
      type_hash && type_hash[:property_option]

    newproperty(leaf.prop_name, option) do
      desc(leaf.desc) if leaf.desc
      newvalues(*leaf.valid_enum) if leaf.valid_enum
      munge {|val| leaf.munge.call(val)} if leaf.munge
      validate {|val| leaf.validate.call(val)} if leaf.validate
      eval <<-EOS
        def change_to_s(is, should)
          "[#{leaf.full_name}] changed \#{is_to_s(is).inspect} to \#{should_to_s(should).inspect}"
        end
      EOS
      eval <<-EOS if leaf.misc.include?(PuppetX::VMware::Mapper::InheritablePolicyValue)
        def insync?(is)
          v = PuppetX::VMware::Mapper.insyncInheritablePolicyValue(
              is, @resource, \"#{leaf.prop_name}\".to_sym)
          v = super(is) if v.nil?
          v
        end
      EOS
    end
  end
end
