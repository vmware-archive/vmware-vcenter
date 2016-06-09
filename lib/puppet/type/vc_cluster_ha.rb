# Copyright (C) 2013 VMware, Inc.
require 'pathname'
module_lib = Pathname.new(__FILE__).parent.parent.parent

require File.join module_lib, 'puppet_x/vmware/mapper'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet/property/vmware'


Puppet::Type.newtype(:vc_cluster_ha) do
  @doc = "Manages vCenter cluster's settings for HA (High Availability)."

  newparam(:path, :namevar => true) do
    desc "The path to the cluster."

    validate do |value|
      raise "Absolute path required: #{value}" unless Puppet::Util.absolute_path?(value)
    end
  end

  clusterConfigSpecExMap = PuppetX::VMware::Mapper.new_map('ClusterConfigSpecExMap')
  clusterConfigSpecExMap.leaf_list.each do |leaf|
    if leaf.misc.include?(Array)
      option = {
        :array_matching => :all,
        :parent => Puppet::Property::VMware_Array,
      }
    else
      option = {}
    end

    newproperty(leaf.prop_name, option) do
      desc(leaf.desc) if leaf.desc
      newvalues(*leaf.valid_enum) if leaf.valid_enum
      munge {|val| leaf.munge.call(val)} if leaf.munge
      validate {|val| leaf.validate.call(val)} if leaf.validate
      eval <<-EOS
        def change_to_s(is,should)
          "[#{leaf.full_name}] changed \#{is.inspect} to \#{should.inspect}"
        end
      EOS
    end
  end

  # autorequire cluster - same path used for cluster configuration resources
  autorequire(:vc_cluster) do
    Pathname.new(self[:path]).to_s
  end

end
