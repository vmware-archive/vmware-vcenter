#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:vc_vm).provider(:vc_vm) do
  vc_vm_yml =  YAML.load_file(my_fixture('vc_vm.yml'))
  createvm = vc_vm_yml['createvm']

  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']

  let(:create_vm) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:vc_vm).new(
    :name => createvm['name'],
    :ensure      => createvm['ensure'],
    :transport   => transport,
    :catalog     => @catalog,
    
    :operation => 'create',
    :datacenter_name  => 'DDCQA',
    :memorymb  => '2048',
    :numcpu    => '2',
    :host      =>'172.16.100.56',
    :cluster   => '',
    :target_datastore => 'gale-fsr',
    :diskformat=> 'thin',      
  
    :disksize  => '4096',
    :memory_hot_add_enabled  => true,
    :cpu_hot_add_enabled     => true,
  
     :guestid => 'winXPProGuest',
     :portgroup=> 'VM network',
     :nic_count=> '1',
     :nic_type => 'E1000',
    :goldvm    => 'vShield Manager',
   :dnsDomain  => 'asm.test',
   :guestCustomization=> 'false',
   :guesthostname     => 'ClonedVM',
   :guesttype  => 'linux',
   :linuxtimezone     => 'EST',
   :windowstimezone   => '035',
   :guestwindowsdomain=> '',
   :guestwindowsdomainadministrator => '',
   :guestwindowsdomainadminpassword => '',
   :windowsadminpassword     => 'iforgot',
   :productid  => '',
   :windowsguestowner => 'TestOwner',
   :windowsguestorgnization  => 'TestOrg',
   :autologoncount    => '',
   :autousers  => '',
    )
  end

  deletevm = vc_vm_yml['deletevm']

  let (:delete_vm) do
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
    :name => deletevm['name'],
    :ensure      => deletevm['ensure'],
    :transport   => transport,
    :catalog     => @catalog,
    :operation => 'create',
        :datacenter_name  => 'DDCQA',
        :memorymb  => '2048',
        :numcpu    => '2',
        :host      =>'172.16.100.56',
        :cluster   => '',
        :target_datastore => 'gale-fsr',
        :diskformat=> 'thin',      
      
        :disksize  => '4096',
        :memory_hot_add_enabled  => true,
        :cpu_hot_add_enabled     => true,
      
         :guestid => 'winXPProGuest',
         :portgroup=> 'VM network',
         :nic_count=> '1',
         :nic_type => 'E1000',
        :goldvm    => 'vShield Manager',
       :dnsDomain  => 'asm.test',
       :guestCustomization=> 'false',
       :guesthostname     => 'ClonedVM',
       :guesttype  => 'linux',
       :linuxtimezone     => 'EST',
       :windowstimezone   => '035',
       :guestwindowsdomain=> '',
       :guestwindowsdomainadministrator => '',
       :guestwindowsdomainadminpassword => '',
       :windowsadminpassword     => 'iforgot',
       :productid  => '',
       :windowsguestowner => 'TestOwner',
       :windowsguestorgnization  => 'TestOrg',
       :autologoncount    => '',
       :autousers  => '',
    )
  end

  describe "when creating a vm" do
    it "should be able to create vm" do
      #Then
      create_vm.provider.should_receive(:get_operation_name).and_return('create')
      create_vm.provider.should_receive(:create_vm)
      #When
      create_vm.provider.create
    end
  end

  describe "when removing  vm  - which already exists" do
    it "should be able to export vm" do
      #Then
           delete_vm.provider.should_receive(:get_vm_from_datacenter)
           delete_vm.provider.should_receive(:get_power_state)
           delete_vm.provider.should_receive(:delete_vm)
      #When
      delete_vm.provider.destroy
    end
  end
end