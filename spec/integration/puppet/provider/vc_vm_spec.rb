#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:vc_vm).provider(:vc_vm) do

  vc_vm_yml =  YAML.load_file(my_fixture('vc_vm.yml'))
  createvm = vc_vm_yml['create_vm']

  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']

  let(:create_vm) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:vc_vm).new(
    :name                     => createvm['name'],
    :transport                => transport,
    :catalog                  => @catalog,
    :datacenter               => createvm['datacenter'],
    :disk_format              => createvm['disk_format'], 
    :createvm_datastore       => createvm['target_datastore'], 
    :createvm_host            => createvm['target_host'], 
    :createvm_host_datastore  => createvm['target'],
    :disksize                 => createVM['disksize'],
    :memory_hot_add_enabled   => createVM['memory_hot_add_enabled'],
    :cpu_hot_add_enabled      => createVM['cpu_hot_add_enabled'],
    :guestid                  => createVM['guestid'],
    :portgroup                => createVM['portgroup'],
    :nic_count                => createVM['nic_count'],
    :nic_type                 => createVM['nic_type'],
    )
  end 
 
 

  describe "when creating a vm from scratch" do
    it "should be able to create vm from scratch" do
      create_vm.provider.create      
    end
  end

  describe "when creating a vm based on the specified base image" do
    it "should be able to create vm based on the specified base image" do
      clone_vm.provider.create
    end
  end

  describe "when creating a vm based on the specified base image template" do
    it "should be able to create a vm based on the specified base image template" do
      clone_vm.provider.create   
    end
  end
  
  describe "when deleting a vm" do
    it "should be able to delete vm" do
      create_vm.provider.delete   
    end
  end


end
