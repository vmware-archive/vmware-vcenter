require 'spec_helper'

describe Puppet::Type.type(:esx_portgroup) do

  let(:title) { 'esx_portgroup' }

  context 'should compile with given test params' do
    let(:params) { {
        :name => 'esx1:portgroup1',
        :ensure => present,
        :portgrouptype => 'VMkernel',
        :overridefailback => 'Enabled',
        :failback => false,
        :mtu => '2019',
        :overridefailoverorder => 'Enabled',
        :nicorderpolicy => {
        activenic  => ["vmnic1", "vmnic4"],
        standbynic => ["vmnic3", "vmnic2"]
        },
        :overridecheckbeacon => 'Enabled',
        :checkbeacon    => true,
        :vmotion => 'Enabled',
        :ipsettings => 'static',
        :ipaddress => '172.16.104.52',
        :subnetmask => '255.255.255.0',
        :traffic_shaping_policy => 'Enabled',
        :averagebandwidth => '5000',
        :peakbandwidth => '7027',
        :burstsize => '2085',
        :vswitch => 'vSwitch1',
        :path => '/datacenter1/cl1',
        :vlanid => '1',
      }}
    it do
      expect {
        should compile
      }
    end

  end

  context "when validating attributes" do

    it "should have name as its keyattribute" do
      described_class.key_attributes.should == [:name]
    end

    describe "when validating attributes" do
      [:name, :portgrp, :path, :vswitch, :host, :nicorderpolicy, :portgrouptype, :averagebandwidth, :peakbandwidth, :burstsize, :ipaddress, :subnetmask, :checkbeacon, :failback, ].each do |param|
        it "should be a #{param} parameter" do
          described_class.attrtype(param).should == :param
        end
      end

      [:ensure, :traffic_shaping_policy, :mtu, :overridefailoverorder, :overridecheckbeacon, :overridefailback, :vmotion, :ipsettings, :vlanid, ].each do |property|
        it "should be a #{property} property" do
          described_class.attrtype(property).should == :property
        end
      end
    end

    describe "when validating values" do

      describe "validating name param" do
        it "should allow a valid name" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:name].should == 'esx1:portgroup1'
        end

        it "should not allow blank value in the name" do
          expect { described_class.new(:name => '', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1') }.to raise_error Puppet::Error
        end
      end

      describe "validating ensure property" do
        it "should support present value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:ensure].should == :present
        end

        it "should support absent value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :absent, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:ensure].should == :absent
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:name => 'esx1:portgroup1', :ensure => :foo, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1') }.to raise_error Puppet::Error
        end

      end

      describe "validating path param" do
        it "should be a valid path" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:path].should == '/datacenter1/cl1'
        end

        it "should not allow invalid path values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '####datacenter1', :vlanid => '1')}.to raise_error Puppet::Error
        end

      end

      describe "validating vswitch param" do
        it "should be a valid vswitch name" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:vswitch].should == 'vSwitch1'
        end

        it "should not blank/empty vswitch name values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => '', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end

      end

      describe "validating portgrouptype param" do
        it "should be a valid portgrouptype param value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:portgrouptype].should.to_s == 'VMkernel'
        end

        it "should not allow invalid portgrouptype param values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'foo', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating averagebandwidth param" do
        it "should be a valid averagebandwidth value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:averagebandwidth].should == '5000'
        end
      end

      describe "validating peakbandwidth param" do
        it "should be a valid peakbandwidth value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:peakbandwidth].should == '7027'
        end
      end

      describe "validating burstsize param" do
        it "should be a valid burstsize value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:burstsize].should == '2085'
        end
      end

      describe "validating ipaddress param" do
        it "should be a valid ipaddress value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:ipaddress].should == '172.16.104.52'
        end
      end

      describe "validating subnetmask param" do
        it "should be a valid subnetmask value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:subnetmask].should == '255.255.255.0'
        end
      end

      describe "validating traffic_shaping_policy property" do
        it "should be a valid traffic_shaping_policy value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:traffic_shaping_policy].should.to_s == 'Enabled'
        end

        it "should not allow invalid traffic_shaping_policy values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'foo', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating checkbeacon param" do
        it "should be a valid checkbeacon value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:checkbeacon].should.to_s == 'true'
        end

        it "should not allow invalid checkbeacon values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => false, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating failback param" do
        it "should be a valid failback value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:failback].should.to_s == 'Enabled'
        end

        it "should not allow invalid failback values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => :foo, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating mtu property" do
        it "should be a valid mtu value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:mtu].should.to_s == '2019'
        end

        it "should not allow invalid mtu values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '20190',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end

        it 'should allow mtu as a fixnum' do
          described_class.new(
            :name => 'esx1:portgroup1',
            :ensure => :present,
            :portgrouptype => 'VMkernel',
            :overridefailback => 'enabled',
            :failback => true,
            :mtu => 2019,
            :overridefailoverorder => 'enabled',
            :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"],
            :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'enabled',
            :checkbeacon => true,
            :vmotion => 'enabled',
            :ipsettings => 'static',
            :ipaddress => '172.16.104.52',
            :subnetmask => '255.255.255.0',
            :traffic_shaping_policy => 'enabled',
            :averagebandwidth => '5000',
            :peakbandwidth => '7027',
            :burstsize => '2085',
            :vswitch => 'vSwitch1',
            :path => '/datacenter1/cl1',
            :vlanid => '1'
          )[:mtu].should.to_s == 2019
        end
      end

      describe "validating overridefailoverorder property" do
        it "should be a valid overridefailoverorder value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:overridefailoverorder].should.to_s == 'Enabled'
        end

        it "should not allow invalid overridefailoverorder values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
            :overridefailoverorder => 'foo', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating overridecheckbeacon property" do
        it "should be a valid overridecheckbeacon value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:overridecheckbeacon].should.to_s == 'Enabled'
        end

        it "should not allow invalid overridefailoverorder values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'foo', :checkbeacon => :foo, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating overridefailback property" do
        it "should be a valid overridefailback value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:overridefailback].should.to_s == 'Enabled'
        end

        it "should not allow invalid overridefailback values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'foo', :failback => true, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'Enabled', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating vmotion property" do
        it "should be a valid vmotion value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:vmotion].should.to_s == 'Enabled'
        end

        it "should not allow invalid vmotion values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'foo', :ipsettings => 'static',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating ipsettings property" do
        it "should be a valid ipsettings value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:ipsettings].should.to_s == 'static'
        end

        it "should not allow invalid ipsettings values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'foo', :ipsettings => 'foo',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')}.to raise_error Puppet::Error
        end
      end

      describe "validating vlanid property" do
        it "should be a valid vlanid value" do
          described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
          :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
          :overridecheckbeacon => 'Enabled', :checkbeacon => true, :vmotion => 'Enabled', :ipsettings => 'static',
          :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
          :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '1')[:ipsettings].should.to_s == 'static'
        end

        it "should not allow invalid vlanid values" do
          expect {described_class.new(:name => 'esx1:portgroup1', :ensure => :present, :portgrouptype => 'VMkernel', :overridefailback => 'Enabled', :failback => true, :mtu => '2019',
            :overridefailoverorder => 'Enabled', :nicorderpolicy => {:activenic  => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]},
            :overridecheckbeacon => 'Enabled', :checkbeacon => :foo, :vmotion => 'foo', :ipsettings => 'foo',
            :ipaddress => '172.16.104.52', :subnetmask => '255.255.255.0', :traffic_shaping_policy => 'Enabled', :averagebandwidth => '5000', :peakbandwidth => '7027', :burstsize => '2085',
            :vswitch => 'vSwitch1', :path => '/datacenter1/cl1', :vlanid => '')}.to raise_error Puppet::Error
        end
      end

    end
  end
end
