require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_datastore/esx_datastore_fixture'

describe "esx datastore behavior testing" do
  before(:each) do
     @fixture = Esx_datastore_fixture.new       
  end
   
  context "when esx_datastore provider is created " do
     it "should have a create method defined for esx_datastore" do
       @fixture.provider.class.instance_method(:create).should_not == nil
     end
 
     it "should have a destroy method defined for esx_datastore" do
       @fixture.provider.class.instance_method(:destroy).should_not == nil
     end
 
     it "should have a exists? method defined for esx_datastore" do
       @fixture.provider.class.instance_method(:exists?).should_not == nil
     end
 
     it "should have a parent 'Puppet::Provider::Vcenter'" do
       @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
     end
  end

  context "when esx_datastore is created " do
    it "should create datastore" do
      @fixture.provider.expects(:create_vmfs_lun).returns(true)
      @fixture.provider.expects(:exists?).returns(true)

      @fixture.provider.create
    end

    it "should destroy datastore" do
      @fixture.provider.expects(:destroy).returns(0)

      Puppet.expects(:err).never

      @fixture.provider.destroy
    end
  end

  describe "#existing_vmfs?" do
    let(:disk_info) {mock("disk_info")}
    let(:disk_options) {mock("options")}
    let(:host) {mock("host")}
    let(:disk) {mock("disk")}
    let(:datastore_system) {"datastoreSystem"}
    let(:config_manager) {"configManager"}

    before(:each) do
      disk_options.stubs(:info).returns(disk_info)
      datastore_system.stubs(:QueryVmfsDatastoreCreateOptions).returns([disk_options])
      config_manager.stubs(:datastoreSystem).returns(datastore_system)
      host.stubs(:configManager).returns(config_manager)
      @fixture.provider.stubs(:host).returns(host)
      disk.stubs(:deviceName).returns("test_path")
    end

    it "should return true when no partition change required because VMFS exists" do
      disk_info.stubs(:partitionFormatChange).returns(false)
      expect(@fixture.provider.existing_vmfs?(disk)).to eq(true)
    end

    it "should return false when a partition change is required because no VMFS exists" do
      disk_info.stubs(:partitionFormatChange).returns(true)
      expect(@fixture.provider.existing_vmfs?(disk)).to eq(false)
    end
  end
end
