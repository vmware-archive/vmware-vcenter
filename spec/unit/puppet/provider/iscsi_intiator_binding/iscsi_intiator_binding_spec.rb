require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/iscsi_intiator_binding/iscsi_intiator_binding_fixture'

describe "iscsi initiator binding testing" do
  before(:each) do
     @fixture = Iscsi_intiator_binding_fixture.new
       
   end
   
  context "when iscsi_intiator_binding provider is created " do
     it "should have a create method defined for iscsi_intiator_binding" do
       @fixture.provider.class.instance_method(:create).should_not == nil
     end
 
     it "should have a destroy method defined for iscsi_intiator_binding" do
       @fixture.provider.class.instance_method(:destroy).should_not == nil
     end
 
     it "should have a exists? method defined for iscsi_intiator_binding" do
       @fixture.provider.class.instance_method(:exists?).should_not == nil
     end
 
     it "should have a parent 'Puppet::Provider::Vcentre'" do
       @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
     end
  end
   
  context "when iscsi_intiator_binding is created " do
     it "should bind HBA to VMkernel nic" do
     #Then
       @fixture.provider.stub(:execute_system_cmd).and_return(0)
       @fixture.provider.should_receive(:execute_system_cmd)
       Puppet.should_receive(:notice).at_least(:once)

       
       #When
       @fixture.provider.create
     end 
        
    it "should not bind HBA to VMkernel nic if command executed with some error" do
        #Then
          @fixture.provider.stub(:execute_system_cmd).and_return(1)
          @fixture.provider.should_receive(:execute_system_cmd)
          Puppet.should_receive(:err)
          
          #When
          @fixture.provider.create
        end 
   end
   
  context "when iscsi_intiator_binding calls destroy " do
       it "should remove HBA binding from VMkernel nic" do
       #Then
         @fixture.provider.stub(:execute_system_cmd).and_return(0)
         @fixture.provider.should_receive(:execute_system_cmd)
         Puppet.should_receive(:notice).at_least(:once)
         
         #When
         @fixture.provider.destroy
       end 
          
      it "should not export ovf if vm does not exist" do
       #Then
         @fixture.provider.stub(:execute_system_cmd).and_return(1)
         @fixture.provider.should_receive(:execute_system_cmd)
         Puppet.should_receive(:err)
            
       #When
        @fixture.provider.destroy
      end 
   end
   
   
end