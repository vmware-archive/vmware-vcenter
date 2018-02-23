require 'spec_helper'

describe Puppet::Type.type(:vc_vm_ovf) do
  let(:title) { 'vc_vm_ovf' }

  context 'should compile with given test params' do
    let(:params) { {
		 :name           => 'testVM_1',
         :ovffilepath      => '/root/OVF/test_123.ovf',
         :datacenter       => 'DDCQA',
         :target_datastore => 'datastore3',
         :host             => '172.16.100.56',
         :disk_format      => 'thin',
		 :ensure           => 'import', 
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

        it "should support import" do
          described_class.new(:name => 'testVM_1',:ovffilepath => '/root/OVF/test_123.ovf', :datacenter => 'DDCQA', :target_datastore => 'datastore3', :host    => '172.16.100.56', :disk_format => 'thin', :ensure  => 'import')[:ensure].should == :import
        end

        it "should support export" do
          described_class.new(:name => 'testVM_1',:ovffilepath => '/root/OVF/test_123.ovf', :datacenter => 'DDCQA', :target_datastore => 'datastore3', :host    => '172.16.100.56', :disk_format => 'thin', :ensure  => 'export')[:ensure].should == :export
        end

        it "should not support other values" do
          expect { described_class.new(:name => 'testVM_1',:ovffilepath => '/root/OVF/test_123.ovf', :datacenter => 'DDCQA', :target_datastore => 'datastore3', :host    => '172.16.100.56', :disk_format => 'thin', :ensure  => 'negativetest') }.to raise_error(Puppet::Error, /Invalid value "negativetest"/)
        end
      end
    end

  end


