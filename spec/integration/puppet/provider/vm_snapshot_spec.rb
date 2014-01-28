#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:vm_snapshot).provider(:vm_snapshot) do
let :snapshot do
  
transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')
  
transport_yaml = YAML.load_file(transport_yaml)
transport_node = transport_yaml['transport']
  
snapshot_yaml = YAML.load_file(integration_yaml)
snapshot_node = snapshot_yaml['vm_snapshot']
    
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
  :name => snapshot_node['name'], 
  :snapshot_operation => snapshot_node['snapshot_operation'],
  :transport => transport,
  :catalog => catalog,
  :memory_snapshot => snapshot_node['memory_snapshot'],
  :datacenter => snapshot_node['datacenter'], 
  :vm_name => snapshot_node['vm_name'], 
  )
  
end

describe "When managing the snapshot" do
  it "should create snapshot" do
      response = snapshot.provider.snapshot_operation=(:create)     
      response.should_not be_nil
    end
    it "should revert snapshot" do
      response = snapshot.provider.snapshot_operation=(:revert)
      response.should_not be_nil  
    end
    it "should remove snapshot" do
      response = snapshot.provider.snapshot_operation=(:remove) 
      response.should_not be_nil
    end
end
end