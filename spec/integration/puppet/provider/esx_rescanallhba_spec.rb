#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')

describe Puppet::Type.type(:esx_rescanallhba).provider(:esx_rescanallhba) do

let :rescanHBA do
transport_yaml = YAML.load_file(transport_yaml)
transport_node = transport_yaml['transport']
  
rescanallhba_yaml = YAML.load_file(integration_yaml)
rescanallhba_node = rescanallhba_yaml['esx_rescanallhba']
    
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
  :host => rescanallhba_node['host'],
  :transport => transport,
  :catalog => catalog,
  :path => rescanallhba_node['path'],
  )
end
  
 describe "when rescanning the HBAs" do
  it "should rescan all HBAs, VMFS and refresh host storage system" do
    response = rescanHBA.provider.create    
    response.should be_nil  
  end
end
end
