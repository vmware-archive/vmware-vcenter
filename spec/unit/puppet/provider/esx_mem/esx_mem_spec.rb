require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_mem/esx_mem_fixture'

describe "esx mem configuration and installation behavior testing" do
  before(:each) do
     @fixture = Esx_mem_fixture.new       
  end
   
  context "when esx_mem provider is created " do
     it "should have a getter method of configure_mem defined for esx_mem" do
       @fixture.provider.class.instance_method(:configure_mem).should_not == nil
     end
 
     it "should have a setter method of configure_mem defined for esx_mem" do
       @fixture.provider.class.instance_method(:configure_mem=).should_not == nil
     end
 
     it "should have a getter method of install_mem defined for esx_mem" do
       @fixture.provider.class.instance_method(:install_mem).should_not == nil
     end

     it "should have a setter method of install_mem defined for esx_mem" do
       @fixture.provider.class.instance_method(:install_mem=).should_not == nil
     end
	 
     it "should have a parent 'Puppet::Provider::Vcenter'" do
       @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
     end
  end

  context "when esx_mem is created " do
     it "should configure mem" do
       #Then
       @fixture.provider.stub(:esx_main_enter_exists).and_return(0)
	   @fixture.provider.stub(:execute_system_cmd).and_return(0)
	   @fixture.provider.stub(:esx_main_enter_exists).and_return(0)
	   
	   @fixture.provider.should_receive(:esx_main_enter_exists)
	   @fixture.provider.should_receive(:execute_system_cmd)
	   @fixture.provider.should_receive(:esx_main_enter_exists)

	   Puppet.should_not_receive(:err)
       
       #When
       @fixture.provider.configure_mem=('test')
     end 
  

	 
    it "should install mem" do
       #Then
       @fixture.provider.stub(:esx_main_enter_exists).and_return(0)
	   @fixture.provider.should_receive(:esx_main_enter_exists)
	   
       @fixture.provider.stub(:execute_system_cmd).and_return(0)
	   @fixture.provider.should_receive(:execute_system_cmd)
	   
       @fixture.provider.stub(:esx_main_enter_exists).and_return(0)       
       @fixture.provider.should_receive(:esx_main_enter_exists)
	   
	   Puppet.should_not_receive(:err)
       
       #When
       @fixture.provider.install_mem=('test')
    end 

  end
  
end