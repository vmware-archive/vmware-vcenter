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
       #Then
       @fixture.provider.stub(:create_vmfs_lun).and_return(0)
       @fixture.provider.should_receive(:create_vmfs_lun)
	   @fixture.provider.stub(:exists?).and_return(true)
       @fixture.provider.should_receive(:exists?)

       #When
       @fixture.provider.create
     end 
        
    it "should not create datastore" do
        #Then
        @fixture.provider.stub(:create_vmfs_lun).and_return(1)
        @fixture.provider.should_receive(:create_vmfs_lun)
        @fixture.provider.stub(:exists?).and_return(false)
        @fixture.provider.should_receive(:exists?)

        #When
        @fixture.provider.create
    end

    it "should destroy datastore" do
       #Then
       @fixture.provider.stub(:destroy).and_return(0)
       @fixture.provider.should_receive(:destroy)
	   Puppet.should_not_receive(:err)
       #When
       @fixture.provider.destroy
     end 
  end
end