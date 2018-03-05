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
      @fixture.provider.expects(:enterMaintenanceMode)
      @fixture.provider.expects(:execute_system_cmd).returns(0)
      @fixture.provider.expects(:exitMaintenanceMode).returns(0)

      Puppet.expects(:err).never

      @fixture.provider.configure_mem = ('test')
    end

    it "should install mem" do
      #Then
      @fixture.provider.expects(:enterMaintenanceMode)

      @fixture.provider.expects(:execute_system_cmd).returns(0)

      @fixture.provider.expects(:exitMaintenanceMode)
      @fixture.provider.expects(:toggle_ssh)
      @fixture.provider.expects(:restart_hostd)
      @fixture.provider.expects(:reset_ssh)

      Puppet.expects(:err).never

      #When
      @fixture.provider.install_mem = ('test')
    end
  end
end