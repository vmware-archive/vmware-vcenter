require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vc_migratevm/vc_migratevm_fixture'

describe "Migrate VM from one host to another" do
  before(:each) do
    @fixture = Vc_migratevm_fixture.new
    @fixture.provider.stubs(:migratevm_host)
    @fixture.provider.stubs(:migratevm_datastore)
    @fixture.provider.stubs(:migratevm_host_datastore)
  end

  context "when vc_migratevm provider is executed " do
    it "should have a migratevm_host method defined for vc_migratevm" do
      @fixture.provider.class.instance_method(:migratevm_host).should_not == nil
    end
    it "should have a migratevm_host= method defined for vc_migratevm" do
      @fixture.provider.class.instance_method(:migratevm_host=).should_not == nil
    end
    it "should have a migratevm_datastore method defined for vc_migratevm" do
      @fixture.provider.class.instance_method(:migratevm_datastore).should_not == nil
    end
    it "should have a migratevm_datastore= method defined for vc_migratevm" do
      @fixture.provider.class.instance_method(:migratevm_datastore=).should_not == nil
    end
    it "should have a migratevm_host_datastore method defined for vc_migratevm" do
      @fixture.provider.class.instance_method(:migratevm_host_datastore).should_not == nil
    end
    it "should have a migratevm_host_datastore= method defined for vc_migratevm" do
      @fixture.provider.class.instance_method(:migratevm_host_datastore=).should_not == nil
    end
    it "should have a parent 'Puppet::Provider::Vcentre'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when vm migrated from one host to another" do
    it "should migrate vm from one host to another" do
      #Then
      @fixture.provider.expects(:get_vm_host).returns("172.16.100.57")
      Puppet.expects(:notice)
      mock_host = Object.new
      @fixture.provider.expects(:get_host_view).returns(mock_host)
      @fixture.provider.stubs(:relocate_vm)

      Puppet.expects(:err).never
      #When
      @fixture.provider.migratevm_host=( @fixture.vc_migratevm[:migratevm_host] )
    end

    it "should not migrate vm if as host does not exits" do
      @fixture.provider.expects(:get_vm_host).returns("172.16.100.57")
      Puppet.expects(:notice)
      @fixture.provider.expects(:get_host_view).returns(nil)

      expect {@fixture.provider.migratevm_host = (@fixture.vc_migratevm[:migratevm_host])}.to raise_error(Puppet::Error, /Unable to find the host '172.16.100.56' because the host is either invalid or does not exist./)
    end

  end

  context "when vm migrated from one datastore to another" do
    it "should migrate vm from one datastore to another " do
      @fixture.provider.expects(:get_vm_ds).returns("datastore2")
      Puppet.expects(:notice)

      mock_datastore = mock('ds_view')
      @fixture.provider.expects(:get_ds_view).returns(mock_datastore)
      @fixture.provider.stubs(:relocate_vm)
      Puppet.expects(:err).never

      @fixture.provider.migratevm_datastore = (@fixture.vc_migratevm[:migratevm_datastore])
    end

    it "should not migrate vm if as host does not exits" do
      @fixture.provider.expects(:get_vm_ds).returns("datastore2")
      @fixture.provider.expects(:get_ds_view).returns("datastore2_view")
      Puppet.expects(:notice)
      @fixture.provider.expects(:fail)

      @fixture.provider.migratevm_datastore=( @fixture.vc_migratevm[:migratevm_datastore] )
    end

  end

  context "when vm migrated from one host to another and from one datastore to another" do
    it "should migrate vm from one host to another and from one datastore to another" do
      @fixture.provider.stubs(:get_vm_host).returns("172.16.100.57")
      @fixture.provider.expects(:get_vm_ds).returns("datastore2")
      Puppet.expects(:notice)
      mock_datastore = mock('ds_view')
      @fixture.provider.expects(:get_ds_view).returns(mock_datastore)
      mock_host = Object.new
      @fixture.provider.expects(:get_host_view).returns(mock_host)
      @fixture.provider.stubs(:relocate_vm)
      Puppet.expects(:err).never

      @fixture.provider.migratevm_host_datastore = (@fixture.vc_migratevm[:migratevm_host_datastore])
    end

    it "should not migrate vm if as host does not exits" do
      @fixture.provider.stubs(:get_vm_host).returns("172.16.100.57")
      @fixture.provider.expects(:get_vm_ds).returns("datastore2")
      Puppet.expects(:notice)
      @fixture.provider.expects(:get_host_view).returns(nil)

      expect do
        @fixture.provider.migratevm_host_datastore=( @fixture.vc_migratevm[:migratevm_host_datastore] )
      end.to raise_error(Puppet::Error, /the host is either invalid or does not exist/)
    end
  end
end