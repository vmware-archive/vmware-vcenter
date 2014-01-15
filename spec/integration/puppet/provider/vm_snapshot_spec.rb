#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:vm_snapshot).provider(:vm_snapshot) do
let :snapshot do
transport_yaml = YAML.load_file(my_fixture('transport.yml'))
transport_node = transport_yaml['transport']

catalog = Puppet::Resource::Catalog.new
transport = Puppet::Type.type(:transport).new({
	:name => transport_node['name'],
	:username => transport_node['username'],
	:password => transport_node['password'],
	:server => transport_node['server'],
	:options => transport_node['options'],
})
catalog.add_resource(transport)


Puppet::Type.type(:vm_snapshot).new(
	:name => 'snapshot_integration_test',	
	:snapshot_operation => 'create',
	:transport => transport,
	:catalog => catalog,
	:memory_snapshot => 'false',
	:datacenter => 'AS1000DC',	
	:vm_name => 'dkumar-827-puppet',	
	)
	
end

describe "When managing the snapshot" do
	it "should create snapshot" do
		snapshot.provider.snapshot_operation=(:create) 
	end
	it "should revert snapshot" do
		snapshot.provider.snapshot_operation=(:revert) 
	end
	it "should remove snapshot" do
		snapshot.provider.snapshot_operation=(:remove) 
	end
end
end
