require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vc_migratevm/vc_migratevm_fixture'

describe "Migrate VM from one host to another" do
  before(:each) do
    @fixture = Vc_migratevm_fixture.new
    @fixture.provider.stub(:migratevm_host)
    @fixture.provider.stub(:migratevm_datastore)
    @fixture.provider.stub(:migratevm_host_datastore)
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
      @fixture.provider.stub(:get_vm_host).and_return("172.16.100.57")
      Puppet.should_receive(:notice)
      mock_host=double('host_view')
      @fixture.provider.stub(:get_host_view).and_return(mock_host)
      @fixture.provider.stub(:relocate_vm)

      Puppet.should_not_receive(:err)
      #When
      @fixture.provider.migratevm_host=( @fixture.vc_migratevm[:migratevm_host] )
    end

    it "should not migrate vm if as host does not exits" do
      #Then
      @fixture.provider.stub(:get_vm_host).and_return("172.16.100.57")
      Puppet.should_receive(:notice)
      @fixture.provider.stub(:get_host_view).and_return(nil)
      Puppet.should_receive(:err)
      #when
      @fixture.provider.migratevm_host=( @fixture.vc_migratevm[:migratevm_host] )

    end

  end

  context "when vm migrated from one datastore to another" do
    it "should migrate vm from one datastore to another " do
      #Then
      @fixture.provider.stub(:get_vm_ds).and_return("datastore2")
      Puppet.should_receive(:notice)
      mock_datastore=double('ds_view')
      @fixture.provider.stub(:get_ds_view).and_return(mock_datastore)
      @fixture.provider.stub(:relocate_vm)
      Puppet.should_not_receive(:err)
      #When
      @fixture.provider.migratevm_datastore=( @fixture.vc_migratevm[:migratevm_datastore] )
    end

    it "should not migrate vm if as host does not exits" do
      #Then
      @fixture.provider.stub(:get_vm_ds).and_return("datastore2")
      Puppet.should_receive(:notice)
      @fixture.provider.stub(:get_vm_ds).and_return(nil)
      Puppet.should_receive(:err)
      #when
      @fixture.provider.migratevm_datastore=( @fixture.vc_migratevm[:migratevm_datastore] )

    end

  end

  context "when vm migrated from one host to another and from one datastore to another" do
    it "should migrate vm from one host to another and from one datastore to another" do
      #Then
      @fixture.provider.stub(:get_vm_host).and_return("172.16.100.57")
      @fixture.provider.stub(:get_vm_ds).and_return("datastore2")
      Puppet.should_receive(:notice)
      mock_datastore=double('ds_view')
      @fixture.provider.stub(:get_ds_view).and_return(mock_datastore)
      mock_host=double('host_view')
      @fixture.provider.stub(:get_host_view).and_return(mock_host)
      @fixture.provider.stub(:relocate_vm)
      Puppet.should_not_receive(:err)
      #When
      @fixture.provider.migratevm_host_datastore=( @fixture.vc_migratevm[:migratevm_host_datastore] )
    end

    it "should not migrate vm if as host does not exits" do
      #Then
      @fixture.provider.stub(:get_vm_host).and_return("172.16.100.57")
      @fixture.provider.stub(:get_vm_ds).and_return("datastore2")
      Puppet.should_receive(:notice)
      @fixture.provider.stub(:get_host_view).and_return(nil)
      Puppet.should_receive(:err)
      #when
      @fixture.provider.migratevm_host_datastore=( @fixture.vc_migratevm[:migratevm_host_datastore] )

    end

    it "should not migrate vm if as host does not exits" do
      #Then
      @fixture.provider.stub(:get_vm_host).and_return("172.16.100.57")
      @fixture.provider.stub(:get_vm_ds).and_return("datastore2")
      Puppet.should_receive(:notice)
      @fixture.provider.stub(:get_vm_ds).and_return(nil)
      Puppet.should_receive(:err)
      #when
      @fixture.provider.migratevm_host_datastore=( @fixture.vc_migratevm[:migratevm_host_datastore] )

    end

  end

end