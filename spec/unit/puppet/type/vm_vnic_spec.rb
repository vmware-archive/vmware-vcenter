require 'spec_helper'

describe Puppet::Type.type(:vm_vnic) do

  let(:title) { 'vm_vnic' }

  context 'should compile with given test params' do
    let(:params) { {
        :name => 'Network adapter 1',
        :ensure => present,
        :vm_name => 'testVm',
        :portgroup => 'portgroup1',
        :nic_type => 'E1000',
        :datacenter => "datacenter1"
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
      [:name, :vm_name, :nic_type, :datacenter].each do |param|
        it "should be a #{param} parameter" do
          described_class.attrtype(param).should == :param
        end
      end

      [:ensure, :portgroup].each do |property|
        it "should be a #{property} property" do
          described_class.attrtype(property).should == :property
        end
      end
    end

    describe "when validating values" do

      describe "validating name param" do
        it "should allow a valid name" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:name].should == 'Network adapter 1'
        end

        it "should not allow blank value in the name" do
          expect { described_class.new(:name => '', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
            :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating portgroup param" do
        it "should allow a valid portgroup" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:portgroup].should == 'portgroup1'
        end

        it "should not allow blank value in the portgroup" do
          expect { described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => '', :nic_type => 'E1000',
            :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating vm_name param" do
        it "should allow a valid vm_name" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:vm_name].should == 'testVm'
        end

        it "should not allow blank value in the vm_name" do
          expect { described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => '', :portgroup => 'portgroup1', :nic_type => 'E1000',
            :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating datacenter param" do
        it "should allow a valid datacenter" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:datacenter].should == 'datacenter1'
        end

        it "should not allow blank value in the datacenter" do
          expect { described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
            :datacenter => '') }.to raise_error Puppet::Error
        end
      end

      describe "validating ensure property" do

        it "should support present value" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:ensure].should == :present
        end

        it "should support absent value" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'absent', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:ensure].should == :absent
        end

        it "should not allow values other than present or absent" do
          expect { described_class.new(:name => 'Network adapter 1', :ensure => 'foo', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
            :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end

      describe "validating nic_type param" do

        it "should support E1000 value" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'E1000',
          :datacenter => 'datacenter1')[:nic_type].should == :E1000
        end

        it "should support :VMXNET 2 value" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'VMXNET 2',
          :datacenter => 'datacenter1')[:nic_type].should == :"VMXNET 2"
        end

        it "should support :VMXNET 3 value" do
          described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'VMXNET 3',
          :datacenter => 'datacenter1')[:nic_type].should == :"VMXNET 3"
        end

        it "should not allow values other than E1000 or VMXNET 2 or VMXNET 3" do
          expect { described_class.new(:name => 'Network adapter 1', :ensure => 'present', :vm_name => 'testVm', :portgroup => 'portgroup1', :nic_type => 'garbage',
            :datacenter => 'datacenter1') }.to raise_error Puppet::Error
        end
      end
    end
  end
end
