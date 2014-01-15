require 'spec_helper'

describe Puppet::Type.type(:vc_vm) do
  let(:title) { 'vc_vm' }

  context 'should compile with given test params' do
    let(:params) { {
      :name    => 'UbuntuCloneGuestVM',
      :operation => 'create',
      :datacenter_name  => 'DDCQA',
      :memorymb  => '2048',
      :numcpu    => '2',
      :host      =>'172.16.100.56',
      :cluster   => '',
      :target_datastore => 'gale-fsr',
      :diskformat=> 'thin',
      :disksize  => 4096,
      :memory_hot_add_enabled  => true,
      :cpu_hot_add_enabled     => true,    
      :guestid => 'winXPProGuest',
      :portgroup=> 'VM network',
      :nic_count=> 1,
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
     :ensure    => 'present', 
      }}
    it do
      expect {
 should compile
      }
    end

  end

  it "should have vmname as one of its parameters for vm name" do
    described_class.key_attributes.should == [:name]
  end

  

    context "when validating values" do

describe "validating ensure property" do

 it "should support present" do
   described_class.new(:name => 'UbuntuCloneGuestVM',:operation=> 'create',:datacenter_name => 'DDCQA',:memorymb => '2048',:numcpu => '2',:host   =>'172.16.100.56',:cluster=> '',:target_datastore=> 'gale-fsr',:diskformat => 'thin',:disksize => '4096',:memory_hot_add_enabled    => true,:cpu_hot_add_enabled => true,    :guestid=> 'winXPProGuest', :portgroup => 'VM network', :nic_count => '1', :nic_type=> 'E1000', :goldvm => 'vShield Manager', :dnsDomain => 'asm.test',      :guestCustomization   => 'false',      :guesthostname    => 'ClonedVM',      :guesttype => 'linux',      :linuxtimezone    => 'EST',      :windowstimezone  => '035',      :guestwindowsdomain   => '',      :guestwindowsdomainadministrator => '',      :guestwindowsdomainadminpassword => '',      :windowsadminpassword => 'iforgot',      :productid  => '',      :windowsguestowner=> 'TestOwner',      :windowsguestorgnization    => 'TestOrg',      :autologoncount   => '',      :autousers => '', :ensure => 'present',)[:ensure].should == :present
 end

 it "should support absent" do
   described_class.new(:name => 'UbuntuCloneGuestVM',:operation=> 'create',:datacenter_name => 'DDCQA',:memorymb => '2048',:numcpu => '2',:host   =>'172.16.100.56',:cluster=> '',:target_datastore=> 'gale-fsr',:diskformat => 'thin',:disksize => '4096',:memory_hot_add_enabled    => true,:cpu_hot_add_enabled => true,    :guestid=> 'winXPProGuest', :portgroup => 'VM network', :nic_count => '1', :nic_type=> 'E1000', :goldvm => 'vShield Manager', :dnsDomain => 'asm.test',      :guestCustomization   => 'false',      :guesthostname    => 'ClonedVM',      :guesttype => 'linux',      :linuxtimezone    => 'EST',      :windowstimezone  => '035',      :guestwindowsdomain   => '',      :guestwindowsdomainadministrator => '',      :guestwindowsdomainadminpassword => '',      :windowsadminpassword => 'iforgot',      :productid  => '',      :windowsguestowner=> 'TestOwner',      :windowsguestorgnization    => 'TestOrg',      :autologoncount   => '',      :autousers => '', :ensure => 'absent',)[:ensure].should == :absent
 end

 it "should not support other values" do
   expect { described_class.new(:name => 'UbuntuCloneGuestVM',:operation=> 'create',:datacenter_name => 'DDCQA',:memorymb => '2048',:numcpu => '2',:host   =>'172.16.100.56',:cluster=> '',:target_datastore=> 'gale-fsr',:diskformat => 'thin', :disksize => '4096',:memory_hot_add_enabled    => true,:cpu_hot_add_enabled => true,    :guestid=> 'winXPProGuest', :portgroup => 'VM network', :nic_count => '1', :nic_type=> 'E1000', :goldvm => 'vShield Manager', :dnsDomain => 'asm.test',      :guestCustomization   => 'false',      :guesthostname    => 'ClonedVM',      :guesttype => 'linux',      :linuxtimezone    => 'EST',      :windowstimezone  => '035',      :guestwindowsdomain   => '',      :guestwindowsdomainadministrator => '',      :guestwindowsdomainadminpassword => '',      :windowsadminpassword => 'iforgot',      :productid  => '',      :windowsguestowner=> 'TestOwner',      :windowsguestorgnization    => 'TestOrg',      :autologoncount   => '',      :autousers => '',      :ensure=>  'negativetest') }.to raise_error(Puppet::Error, /Invalid value "negativetest"/)
 end
      end
    end

  end
