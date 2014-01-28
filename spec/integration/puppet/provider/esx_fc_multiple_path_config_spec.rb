#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')

describe Puppet::Type.type(:esx_fc_multiple_path_config).provider(:esx_fc_multiple_path_config ) do

let :multiPathConfig do
  transport_yaml = YAML.load_file(transport_yaml)
  transport_node = transport_yaml['transport']
  
  multiple_path_yaml = YAML.load_file(integration_yaml)
  multiple_path_node = multiple_path_yaml['esx_fc_multiple_path_config']

catalog = Puppet::Resource::Catalog.new
transport = Puppet::Type.type(:transport).new({
  :name => transport_node['name'],
  :username => transport_node['username'],
  :password => transport_node['password'],
  :server => transport_node['server'],
  :options => transport_node['options'],
})
catalog.add_resource(transport)

Puppet::Type.type(:esx_fc_multiple_path_config).new(
  :host => multiple_path_node['host'],
  :policyname => multiple_path_node['policyname'],  
  :transport => transport,
  :catalog => catalog,
  :path => multiple_path_node['path'],
  )
end

describe "When changing the multiple FC path configuration" do
  it "should change to Round Robin on all FC HBAs" do
    response = multiPathConfig.provider.create  
    response.should be_nil
  end
end
end
