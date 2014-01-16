#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_maintmode).provider(:esx_maintmode) do

let :esx_maintmode do
transport_yaml = YAML.load_file(my_fixture('transport.yml'))
transport_node = transport_yaml['transport']
  
maintmode_yml = YAML.load_file(my_fixture('esx_maintmode.yml'))
maintmode_node = maintmode_yml['maintmode']

catalog = Puppet::Resource::Catalog.new

transport = Puppet::Type.type(:transport).new({
	:name => transport_node['name'],
	:username => transport_node['username'],
	:password => transport_node['password'],
	:server => transport_node['server'],
	:options => transport_node['options'],
})

catalog.add_resource(transport)

Puppet::Type.type(:esx_maintmode).new(
	:hostseq => maintmode_node['hostseq'],	
	:transport => transport,
	:catalog => catalog	
	)
end

describe "Testing Host for being put in maintenance mode or exiting from it" do
	it "should put host in maintenance mode" do
	   expect { esx_maintmode.provider.enterMaintenanceMode }.to_not raise_error 
	end
	
	it "should exit host from maintenance mode" do    
    expect { esx_maintmode.provider.exitMaintenanceMode }.to_not raise_error 
	end
	
end
end
