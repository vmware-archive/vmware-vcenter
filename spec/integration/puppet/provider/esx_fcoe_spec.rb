#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_fcoe).provider(:esx_fcoe) do

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

let :fcoe do
transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')
  
transport_yaml = YAML.load_file(transport_yaml)
transport_node = transport_yaml['transport']
  
fcoe_yaml = YAML.load_file(integration_yaml)
fcoe_node = fcoe_yaml['esx_fcoe']

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
  :name => fcoe_node['name'], 
  :path => fcoe_node['path'],   
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
