#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:vc_migratevm).provider(:vc_migratevm) do

  integration_yml =  File.join(provider_path, '/fixtures/integration/integration.yml')
  vc_migratevm_yml = YAML.load_file(integration_yml) 
  migratevm = vc_migratevm_yml['migrate_vm']

  transport_yml =  File.join(provider_path, '/fixtures/integration/transport.yml')
  transport_yml = YAML.load_file(transport_yml)
  transport_node = transport_yml['transport']

  let(:migrate_vm) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:vc_migratevm).new(
    :name                     => migratevm['name'],
    :transport                => transport,
    :catalog                  => @catalog,
    :datacenter               => migratevm['datacenter'],
    :disk_format              => migratevm['disk_format'], 
    :migratevm_datastore      => migratevm['target_datastore'], 
    :migratevm_host           => migratevm['target_host'], 
    :migratevm_host_datastore => migratevm['target'],
    )
  end
  
 
  describe "when vm exists" do
    it "should be able to get VM existance" do
      response = migrate_vm.provider.exists?
      response.should be_true
    end
  end

  describe "when migrating a vm from one host to another" do
    it "should be able to migrate vm from one host to another" do
      migrate_vm.provider.migratevm_host=migratevm['target_host']
      # validating whether vm migrated successfully or not
      migrate_vm.provider.migratevm_host.should eql(migratevm['target_host'])
    end
  end

  describe "when migrating a vm from one datastore to another" do
    it "should be able to migrate vm from one datastore to another" do
      migrate_vm.provider.migratevm_datastore=migratevm['target_datastore']
      # validating whether vm migrated successfully or not
      migrate_vm.provider.migratevm_datastore.should eql(migratevm['target_datastore'])
    end
  end

  describe "when migrating a vm from one host to another and from one datastore to another" do
    it "should be able to migrate vm from one host to another and from one datastore to another" do
      migrate_vm.provider.migratevm_host_datastore=migratevm['target']
      # validating whether vm migrated successfully or not
      vm_updatedhost = migrate_vm.provider.migratevm_host
      vm_updatedds = migrate_vm.provider.migratevm_datastore
      vm_updated_target = "#{vm_updatedhost}, #{vm_updatedds}"
      vm_updated_target.should eql(migratevm['target'])      
    end
  end

end
