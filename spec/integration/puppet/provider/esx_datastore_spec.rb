#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:esx_datastore).provider(:esx_datastore) do  
  esx_datastore_yml =  File.join(provider_path, '/fixtures/integration/integration.yml')
  esx_ds_yaml = YAML.load_file(esx_datastore_yml)  
  createdatastore = esx_ds_yaml['createdatastore']
  
  transport_yml =  File.join(provider_path, '/fixtures/integration/transport.yml')
  transport_yaml = YAML.load_file(transport_yml)
  transport_node = transport_yaml['transport']
    
  let(:create_datastore) do
    @catalog = Puppet::Resource::Catalog.new
      transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
     })
    @catalog.add_resource(transport)

  Puppet::Type.type(:esx_datastore).new(
      :type              => createdatastore['type'],
    :ensure            => createdatastore['ensure'],
    :transport         => transport,  
    :catalog           => @catalog,
    :target_iqn        => createdatastore['target_iqn'],
    :name              => "#{createdatastore['host']}:#{createdatastore['datastore']}"
    )
  end  

  destroydatastore = esx_datastore_yml['destroydatastore']
  
  let :destroy_datastore do
    @catalog = Puppet::Resource::Catalog.new
      transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
     })

    @catalog.add_resource(transport)

  Puppet::Type.type(:esx_datastore).new(
      :type               => destroydatastore['type'],
    :target_iqn         => destroydatastore['target_iqn'],
      :name               => "#{destroydatastore['host']}:#{destroydatastore['datastore']}",
    :ensure             => destroydatastore['ensure'],
    :transport          => transport, 
    :catalog            => @catalog
    )
  end

  describe "when creating a datastore" do
      it "should be able to create datastore" do
        create_datastore.provider.create
        create_datastore.provider.exists?.should_not be_nil
      end
    end

  describe "when removing a datastore - which already exists" do
      it "should be able to remove datastore" do
        destroy_datastore.provider.destroy
        destroy_datastore.provider.exists?.should be_nil
      end
    end
end