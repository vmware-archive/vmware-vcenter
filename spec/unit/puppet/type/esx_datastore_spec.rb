require 'spec_helper'

describe Puppet::Type.type(:esx_datastore) do
  let(:title) { 'esx_datastore' }

  context 'should compile with given test params' do
    let(:params) { {
		 :name             => '172.16.103.186:test_vmfs_datastore',
         :type             => 'vmfs',
         :target_iqn       => 'fc.5000d310005ec401:5000d310005ec437',
		 :ensure           => 'present', 
      }}
    it do
      expect {
        should compile
      }
    end

  end

  it "should have datastore name as one of its parameters" do
    described_class.key_attributes.should == [:name]
  end

    context "when validating values" do

       describe "validating ensure property" do

        it "should support present" do
          described_class.new(:name => '172.16.103.186:test_vmfs_datastore',:type => 'vmfs', :target_iqn => 'fc.5000d310005ec401:5000d310005ec437', :ensure  => 'present')[:ensure].should == :present
        end

        it "should support absent" do
          described_class.new(:name => '172.16.103.186:test_vmfs_datastore',:type => 'vmfs', :target_iqn => 'fc.5000d310005ec401:5000d310005ec437', :ensure  => 'absent')[:ensure].should == :absent
        end

        it "should not support other values" do
          expect { described_class.new(:name => '172.16.103.186:test_vmfs_datastore',:type => 'vmfs', :target_iqbn => 'fc.5000d310005ec401:5000d310005ec437', :ensure  => 'negativetest') }.to raise_error(Puppet::Error, /Invalid value "negativetest"/)
        end
      end
    end

  end