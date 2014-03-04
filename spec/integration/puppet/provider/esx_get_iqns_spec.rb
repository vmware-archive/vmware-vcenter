#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:esx_get_iqns).provider(:esx_get_iqns) do
  integration_yml =  File.join(provider_path, '/fixtures/integration/integration.yml')
  esx_get_iqns_yml = YAML.load_file(integration_yml)  
  getiqns = esx_get_iqns_yml['getiqns']

  transport_yaml =  File.join(provider_path, '/fixtures/integration/transport.yml')
  transport_yaml = YAML.load_file(transport_yaml)
  transport_node = transport_yaml['transport']

  let(:esx_get_iqn) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:esx_get_iqns).new(
    :host               => getiqns['host'],
    :transport          => transport,
    :catalog            => @catalog,
    :hostusername       => getiqns['hostusername'],
    :hostpassword      => getiqns['hostpassword']
    )
  end

  describe "when getting iqns from server" do
    it "should be able to get iqns" do
      expect {  esx_get_iqn.provider.get_esx_iqns}.to_not raise_error       
    end
  end
end