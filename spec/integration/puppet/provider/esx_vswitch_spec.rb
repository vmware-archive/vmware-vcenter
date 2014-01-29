#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:esx_vswitch).provider(:esx_vswitch) do

let :vSwitch do
  
transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')
  
transport_yaml = YAML.load_file(transport_yaml)
transport_node = transport_yaml['transport']
  
vswitch_yaml = YAML.load_file(integration_yaml)
vswitch_node = vswitch_yaml['esx_vswitch']
    
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
  :name => vswitch_node['name'],    
  :path => vswitch_node['path'],  
  :num_ports  => vswitch_node['num_ports'],
  :nics => vswitch_node['nics'],
  :nicorderpolicy => vswitch_node['nicorderpolicy'],
  :mtu  => vswitch_node['mtu'],
  :checkbeacon  => vswitch_node['checkbeacon'], 
  :transport => transport,
  :catalog => catalog,  
  )
end

describe "When managing the vswitch" do
  it "should add the vSwitch" do
      vSwitch.provider.create
      if (vSwitch.provider.exists? == true)
        puts "Successfully added the vSwitch"     
      else      
        fail "Failed to add the vswitch"
      end
    end
    
    it "should remove the vSwitch" do
      vSwitch.provider.destroy
      if (vSwitch.provider.exists? == false)
        puts "successfully removed the vSwitch"
      else    
        fail "Failed to remove the Vswitch"
      end
    end 
end
end
