#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_fcoe).provider(:esx_fcoe) do

let :fcoe do
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

Puppet::Type.type(:esx_fcoe).new(
	:name => '172.28.7.3:vmnic1',	
	:path => '/AS1000DC',		
	:transport => transport,
	:catalog => catalog,	
	)
end

describe "When managing the fcoe" do
  it "should add the fcoe" do
      fcoe.provider.create
      if (fcoe.provider.exists? != 'nil')
        puts "Successfully added the FCOE adapter"
      else
        fail "Failed to add the FCOE adapter"
      end
    end
    
    it "should remove the fcoe" do
      fcoe.provider.destroy
      if (fcoe.provider.exists? == 'nil')
        puts "successfully removed the FCOE adapter"
      else
        fail "Failed to remove the FCOE adapter"
      end
    end	
end
end
