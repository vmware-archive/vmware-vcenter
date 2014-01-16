#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:esx_datastore).provider(:esx_datastore) do  
  esx_datastore_yml =  YAML.load_file(my_fixture('esx_datastore.yml'))
  createdatastore = esx_datastore_yml['createdatastore']  
  
  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']  

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
	  if (create_datastore.provider.exists? != 'nil')
		puts "Successfully created datastore #{createdatastore['datastore']} on host #{createdatastore['host']}."
	  else
		puts "Unable to create the datastore #{createdatastore['datastore']} on host #{createdatastore['host']}."
	  end
    end
  end

  describe "when removing a datastore - which already exists" do
    it "should be able to remove datastore" do
      destroy_datastore.provider.destroy
	  if (destroy_datastore.provider.exists? == nil)
		puts "Successfully removed datastore #{destroydatastore['datastore']} from host #{destroydatastore['host']}."
	  else
		puts "Unable to remove the datastore #{destroydatastore['datastore']} from host #{destroydatastore['host']}."
	  end
    end
  end
end