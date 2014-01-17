#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_rescanallhba).provider(:esx_rescanallhba) do

let :rescanHBA do
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

Puppet::Type.type(:esx_rescanallhba).new(
	:host => '172.28.10.3',
	:transport => transport,
	:catalog => catalog,
	:path => '/AS1000DC'
	)	
end
  
 describe "when rescanning the HBAs" do
	it "should rescan all HBAs, VMFS and refresh host storage system" do
    response = rescanHBA.provider.create    
    response.should be_nil  
	end
end
end
