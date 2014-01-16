require 'spec_helper'

describe Puppet::Type.type(:esx_rescanallhba) do

  let(:title) { 'esx_rescanallhba' }

  context 'should compile with given test params' do
    let(:params) { {
        :ensure   => present,
        :host   => 'esx1',
        :path   => '/datacenter1',
      }}
    it do
      expect {
        should compile
      }
    end

  end

  context "when validating attributes" do

    it "should have host as its keyattribute" do
      described_class.key_attributes.should == [:host]
    end

    describe "when validating attributes" do
      [:host, :path].each do |param|
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

      describe "validating ensure property" do
        it "should support present value" do
          described_class.new(:ensure => :present, :host => 'esx1', :path => '/datacenter1')[:ensure].should == :present
        end

        it "should support absent value" do
          described_class.new(:ensure => :absent, :host => 'esx1', :path => '/datacenter1')[:ensure].should == :absent
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:ensure => :foo, :host => 'esx1', :path => '/datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating path param" do
        it "should be a valid path" do
          described_class.new(:ensure => :present, :host => 'esx1', :path => '/datacenter1')[:path].should == '/datacenter1'
        end

        it "should not allow invalid path values" do
          expect {described_class.new(:ensure => :present, :host => 'esx1', :path => '###########/datacenter1')}.to raise_error Puppet::Error
        end
      end

      describe "validating host param" do
        it "should be a valid host" do
          described_class.new(:ensure => :present, :host => 'esx1', :path => '/datacenter1')[:host].should == 'esx1'
        end

        it "should not allow blank host values" do
          expect {described_class.new(:ensure => :present, :host => '', :path => '/datacenter1')}.to raise_error Puppet::Error
        end
      end

    end
  end
end
