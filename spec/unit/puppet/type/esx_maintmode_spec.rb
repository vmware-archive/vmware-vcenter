require 'spec_helper'

describe Puppet::Type.type(:esx_maintmode) do

  let(:title) { 'esx_maintmode' }

  context 'should compile with given test params' do
    let(:params) { {
        :ensure   => present,
        :hostseq  => '172.16.100.56:e1',
        :host   => '172.16.100.56',
        :timeout => 0,
        :evacuate_powered_off_vms   => true,
      }}
    it do
      expect {
        should compile
      }
    end

  end

  context "when validating attributes" do

    it "should have hostseq as its keyattribute" do
      described_class.key_attributes.should == [:hostseq]
    end

    describe "when validating attributes" do
      [:hostseq, :host, :timeout, :evacuate_powered_off_vms].each do |param|
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
          described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true)[:ensure].should == :present
        end

        it "should support absent value" do
          described_class.new(:ensure => :absent, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true)[:ensure].should == :absent
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:ensure => :foo, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true) }.to raise_error(Puppet::ResourceError, /Invalid value :foo/)
        end
      end

      describe "validating hostseq param" do
        it "should support alphanumeric values" do
          described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true)[:hostseq].should == '172.16.100.56:e1'
        end
      end

      describe "validating host param" do
        it "should support alphanumeric values" do
          described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true)[:host].should == '172.16.100.56'
        end
      end

      describe "validating timeout param" do
        it "should support numeric values" do
          described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true)[:timeout].should == 0
        end

        it "should not support non numeric values" do
          expect {described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 'abc',:evacuate_powered_off_vms => true)}.to raise_error(Puppet::ResourceError)
        end

      end

      describe "validating evacuate_powered_off_vms param" do
        it "should support boolean values" do
          described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => true)[:evacuate_powered_off_vms].should be_true 
        end

        it "should not support non boolean values" do
          expect {described_class.new(:ensure => :present, :hostseq  => '172.16.100.56:e1',:host => '172.16.100.56',:timeout => 0,:evacuate_powered_off_vms => 'abc')}.to raise_error(Puppet::ResourceError)
        end
      end

    end
  end
end
