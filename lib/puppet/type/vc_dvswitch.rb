# Copyright (C) 2013 VMware, Inc.
require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent

vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/mapper'

require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vc_dvswitch) do
  @doc = "Manages vCenter Distributed Virtual Switch"

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:path, :namevar => true) do
    desc "The path to the dvswitch."

    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
  end

  map = PuppetX::VMware::Mapper.new_map('VMwareDVSConfigSpecMap')
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
        def change_to_s(is,should)
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

  # autorequire datacenter
  autorequire(:vc_datacenter) do
    Pathname.new(self[:path]).parent.to_s
  end

end
