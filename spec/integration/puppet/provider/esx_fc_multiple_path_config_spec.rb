#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_fc_mutilple_path_config).provider(:esx_fc_mutilple_path_config ) do

let :multiPathConfig do
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

Puppet::Type.type(:esx_fc_mutilple_path_config).new(
	:host => '172.28.10.3',
	:policyname => 'VMW_PSP_RR',	
	:transport => transport,
	:catalog => catalog,
	:path => '/AS1000DC',
	)
end

describe "When changing the multiple FC path configuration" do
	it "should change to Round Robin on all FC HBAs" do
    response = multiPathConfig.provider.create  
    response.should be_nil
	end
end
end
