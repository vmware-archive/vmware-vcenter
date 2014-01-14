require 'spec_helper'

describe Puppet::Type.type(:vc_vm_register) do
  let(:title) { 'vc_vm_register' }

  context 'should compile with given test params' do
    let(:params) { {
        :name               => 'testVM_1',
        :datacenter         => 'DDCQA',
        :hostip             => '172.16.100.56',
        :astemplate         => 'true',
        :vmpath_ondatastore => '[gale-fsr] QA1/QA1.vmtx',
        :ensure           => 'present',
      }}
    it do
      expect {
        should compile
      }
    end

  end

  it "should have vmname as one of its parameters for  name" do
    described_class.key_attributes.should == [:name]
  end

  

    context "when validating values" do

       describe "validating ensure property" do

        it "should support present" do
          described_class.new(:name => 'testVM_1', :datacenter => 'DDCQA', :hostip => '172.16.100.56', :astemplate => 'true', :vmpath_ondatastore => '[gale-fsr] QA1/QA1.vmtx', :ensure   => 'present')[:ensure].should == :present
        end

        it "should support absent" do
          described_class.new(:name => 'testVM_1', :datacenter => 'DDCQA', :hostip => '172.16.100.56', :astemplate => 'true', :vmpath_ondatastore => '[gale-fsr] QA1/QA1.vmtx', :ensure   =>  'absent')[:ensure].should == :absent
        end

        it "should not support other values" do
          expect { described_class.new(:name => 'testVM_1', :datacenter => 'DDCQA', :hostip => '172.16.100.56', :astemplate => 'true', :vmpath_ondatastore => '[gale-fsr] QA1/QA1.vmtx', :ensure   => 'negativetest') }.to raise_error(Puppet::Error, /Invalid value "negativetest"/)
        end
      end
    end

  end
