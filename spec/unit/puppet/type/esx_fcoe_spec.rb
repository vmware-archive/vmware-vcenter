require 'spec_helper'

describe Puppet::Type.type(:esx_fcoe) do

  let(:title) { 'esx_fcoe' }

  context 'should compile with given test params' do
    let(:params) { {
        :name           => 'esx1:vmnic1',
        :ensure         => present,
        :host           => 'esx1',
        :physical_nic   => 'vmnic1',
        :path           => '/datacenter1',
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
      [:host, :physical_nic, :path].each do |param|
        it "should be a #{param} parameter" do
          described_class.attrtype(param).should == :param
        end
      end

      [:ensure].each do |property|
        it "should be a #{property} property" do
          described_class.attrtype(property).should == :property
        end
      end
    end

    describe "when validating values" do

      describe "validating name param" do
        it "should allow a valid name" do
          described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic1', :path => '/datacenter1')[:name].should == 'esx1:vmnic1'
        end

        it "should not allow blank value in the name" do
          expect { described_class.new(:ensure => :present, :name => '', :host => 'esx1', :physical_nic => 'vmnic1', :path => '/datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating ensure property" do
        it "should support present value" do
          described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic1', :path => '/datacenter1')[:ensure].should == :present
        end

        it "should support absent value" do
          described_class.new(:ensure => :absent, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic1', :path => '/datacenter1')[:ensure].should == :absent
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:ensure => :foo, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic0', :path => '/datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating path param" do
        it "should be a valid path" do
          described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic0', :path => '/datacenter1')[:path].should == '/datacenter1'
        end

        it "should not allow invalid path values" do
          expect {described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic0', :path => '###########/datacenter1')}.to raise_error Puppet::Error
        end
      end

      describe "validating host param" do
        it "should be a valid host" do
          described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic1', :path => '/datacenter1')[:host].should == 'esx1'
        end

        it "should not allow invalid host values" do
          expect {described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => '', :physical_nic => 'vmnic1', :path => '/datacenter1')}.to raise_error Puppet::Error
        end
      end

      describe "validating physical_nic param" do
        it "should be a valid physical_nic" do
          described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => 'vmnic2', :path => '/datacenter1')[:physical_nic].to_s.should == 'vmnic2'
        end

        it "should not allow invalid policyname values" do
          expect {described_class.new(:ensure => :present, :name => 'esx1:vmnic1', :host => 'esx1', :physical_nic => '', :path => '/datacenter1')}.to raise_error Puppet::Error
        end

      end

    end
  end
end
