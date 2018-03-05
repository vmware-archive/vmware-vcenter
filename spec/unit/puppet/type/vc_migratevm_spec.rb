require 'spec_helper'

describe Puppet::Type.type(:vc_migratevm) do
  let(:title) {'vc_migratevm'}

  context 'should compile with given test params' do
    let(:params) {{
        :name => 'testVM_1',
        :datacenter => 'DDCQA',
        :disk_format => 'thin',
        :migratevm_datastore => 'datastore1',
        :migratevm_host => '172.16.100.56',
        :migratevm_host_datastore => '172.16.100.56, datastore3',

    }}
    it do
      expect {
        should compile
      }
    end

  end

  it "should have vmname as one of its parameters for vm name" do
    expect(described_class.key_attributes).to eq([:name])
  end

  context "when validating values" do

    describe "validating migratevm_datastore property" do

      it "should support migratevm_datastore" do
        expect(described_class.new(:name => 'testVM_1', :datacenter => 'DDCQA', :disk_format => 'thin', :migratevm_datastore => 'datastore1')[:migratevm_datastore]).to eq('datastore1')
      end
    end

    describe "validating migratevm_host property" do

      it "should support migratevm_host" do
        expect(described_class.new(:name => 'testVM_1', :datacenter => 'DDCQA', :migratevm_host => '172.16.100.56')[:migratevm_host]).to eq('172.16.100.56')
      end
    end

    describe "validating migratevm_host_datastore property" do

      it "should support migratevm_host_datastore" do
        expect(described_class.new(:name => 'testVM_1', :datacenter => 'DDCQA', :migratevm_host_datastore => '172.16.100.56, datastore3')[:migratevm_host_datastore]).to eq('172.16.100.56, datastore3')
      end
    end
  end
end
