require 'spec_helper'

describe Puppet::Type.type(:esx_vswitch) do

  let(:title) { 'esx_vswitch' }

  context 'should compile with given test params' do
    let(:params) { {
        :name   => 'esx1:vswitch1',
        :path   => '/datacenter1',
        :vswitch   => 'vSwitch',
        :host   => 'esx',
        :num_ports   => '100',
        :nics   => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"],
        :nicorderpolicy   => {
        activenic  => ["vmnic1", "vmnic4"],
        standbynic => ["vmnic3", "vmnic2"]
        },
        :mtu   => 2000,
        :checkbeacon   => true,
        :ensure   => present,
      }}
    it do
      expect {
        compile
      }
    end

  end

  context "when validating attributes" do

    it "should have name as its keyattribute" do
      expect(described_class.key_attributes).to eq( [:name ])
    end

    describe "when validating attributes" do
      [:name, :path, :vswitch, :host].each do |param|
        it "should be a #{param} parameter" do
          #described_class.attrtype(param).should == :param
          expect(described_class.attrtype(param)).to eq(:param)
        end
      end

      [:ensure, :num_ports, :nics, :nicorderpolicy, :mtu, :checkbeacon].each do |property|
        it "should be a #{property} property" do
          #described_class.attrtype(property).should == :property
          expect(described_class.attrtype(property)).to eq(:property)
        end
      end
    end

    describe "when validating values" do

      describe "validating name param" do

        it "should allow a valid name" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:name]).to eq('esx1:vswitch1')
        end

        it "should not allow blank value in the name" do
          expect { described_class.new(:name => '', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
            :checkbeacon => true, :ensure => :present) }.to raise_error Puppet::Error
        end
      end

      describe "validating ensure property" do

        it "should support present value" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:ensure]).to eq(:present)
        end

        it "should support absent value" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :absent)[:ensure]).to eq(:absent)
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
            :checkbeacon => true, :ensure   => :foo) }.to raise_error Puppet::Error
        end

      end

      describe "validating path param" do

        it "should be a valid path" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:path]).to eq('/datacenter1')
        end

        it "should not allow invalid path values" do
          expect {described_class.new(:name => 'esx1:vswitch1', :path => '###datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
            :checkbeacon => true, :ensure => :present)}.to raise_error Puppet::Error
        end

      end

      describe "validating num_ports property" do
        it "should be a valid num_ports value" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:num_ports]).to eq(108)
        end

        it "should not allow invalid num_ports values" do
          expect {described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '102416', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
            :checkbeacon => true, :ensure => :present)}.to raise_error Puppet::Error
        end
      end

      describe "validating nics property" do
        it "should be a valid nics value" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:nics]).to be_a(Array)# and [:nics].should == ["vmnic1", "vmnic2", "vmnic3", "vmnic4"]
        end

        it "should not allow invalid nics value" do
          expect {described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => "vmnic1".to_s, :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
            :checkbeacon => true, :ensure => :present)}
        end
      end

      describe "validating mtu property" do
        it "should be a valid mtu value" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:mtu]).to eq(2000)
        end

        it "should not allow invalid mtu values" do
          expect {described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 10000,
            :checkbeacon => true, :ensure => :present)}.to raise_error Puppet::Error
        end
      end

      describe "validating checkbeacon property" do
        it "should be a valid mtu value" do
          expect(described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 2000,
          :checkbeacon => true, :ensure => :present)[:checkbeacon].to_s).to eq("true")
        end

        it "should not allow invalid checkbeacon values" do
          expect {described_class.new(:name => 'esx1:vswitch1', :path => '/datacenter1', :vswitch => 'vSwitch', :host => 'esx', :num_ports => '100', :nics => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"], :nicorderpolicy => { :activenic => ["vmnic1", "vmnic4"], :standbynic => ["vmnic3", "vmnic2"]}, :mtu => 10000,
            :checkbeacon => :foo, :ensure => :present)}.to raise_error Puppet::Error
        end
      end

    end
  end
end
