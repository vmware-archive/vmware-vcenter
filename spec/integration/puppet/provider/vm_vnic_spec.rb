#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:vm_vnic).provider(:vm_vnic) do

let :vnic do
transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')
  
transport_yaml = YAML.load_file(transport_yaml)
transport_node = transport_yaml['transport']
  
vnic_yaml = YAML.load_file(integration_yaml)
vnic_node = vnic_yaml['vm_vnic']
    
catalog = Puppet::Resource::Catalog.new
transport = Puppet::Type.type(:transport).new({
  :name => transport_node['name'],
  :username => transport_node['username'],
  :password => transport_node['password'],
  :server => transport_node['server'],
  :options => transport_node['options'],
})
catalog.add_resource(transport)


Puppet::Type.type(:vm_vnic).new(
  :name => vnic_node['name'],  
  :vm_name => vnic_node['vm_name'],
  :portgroup => vnic_node['portgroup'],
  :nic_type => vnic_node['nic_type'],
  :datacenter => vnic_node['datacenter'],
  :transport => transport,
  :catalog => catalog,  
  )
  
end

describe "When managing the vnic" do
  it "should create vnic" do
    vnic.provider.create    
    if (vnic.provider.exists? != nil)
      puts "Successfully added the vnic"
    else
      fail "Failed to add the vnic"
    end
  end
  it "should remove vnic" do
    vnic.provider.destroy
    sleep 10
    if (vnic.provider.exists? == nil)
      puts "successfully removed the vnic"
    else
      fail "Failed to remove the vnic"
    end
  end 
end
end
