#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_vswitch).provider(:esx_vswitch) do

let :vSwitch do
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

Puppet::Type.type(:esx_vswitch).new(
	:name => '172.28.7.137:vSwitch5',		
	:path => '/AS1000DCTest123',	
	:num_ports	=> '1024',
	:nics	=> ["vmnic6","vmnic7"],
	:nicorderpolicy => '{
		activenic => ["vmnic6"],
		standbynic	=> ["vmnic7"]
	}',
	:mtu	=> '5000',
	:checkbeacon	=> 'false',	
	:transport => transport,
	:catalog => catalog,	
	)
end

describe "When managing the vswitch" do
	it "should add the vSwitch" do
		vSwitch.provider.create
	end
	
	it "should remove the vSwitch" do
		vSwitch.provider.destroy
	end	
end
end
