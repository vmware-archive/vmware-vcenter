# Copyright (C) 2013 VMware, Inc.
require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent

vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/mapper'

require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:esx_iscsi_targets) do
  @doc = "Manage iSCSI targets."

  newparam(:name, :namevar => true) do
    desc "ESX host:target address"

    munge do |value|
      @resource[:esx_host], @resource[:iscsi_hba_device] = value.split(':',2)
      value
    end
  end

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

  newparam(:esx_host) do
    desc "Name of ESXi host"
  end

  newparam(:type) do
    desc "The iSCSI target type."
    newvalues(:static, :send)
    defaultto(:send)
  end

  newparam(:iscsi_hba_device) do
    desc "HBA on host system"
  end

  map = PuppetX::VMware::Mapper.new_map('HostInternetScsiHbaSendTargetMap')
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
    end
  end
end
