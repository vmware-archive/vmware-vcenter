require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vc_vm_register/vc_vm_register_fixture'

describe "vm register/unregister testing" do
  before(:each) do
     @fixture = Vc_vm_register_fixture.new
       
   end
   
  context "when vc_vm_register provider is created " do
     it "should have a create method defined for vc_vm_register" do
       @fixture.provider.class.instance_method(:create).should_not == nil
     end
 
     it "should have a destroy method defined for vc_vm_register" do
       @fixture.provider.class.instance_method(:destroy).should_not == nil
     end
 
     it "should have a exists? method defined for vc_vm_register" do
       @fixture.provider.class.instance_method(:exists?).should_not == nil
     end
 
     it "should have a parent 'Puppet::Provider::Vcentre'" do
       @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
     end
   end
   
  context "when vc_vm_register is created " do
     it "should raise error if host not exist" do
     #Then
       @fixture.provider.stub(:get_host_view).and_return(nil)
       @fixture.provider.should_receive(:get_host_view)
       @fixture.provider.should_not_receive(:get_template)    
       
       #When
       @fixture.provider.create
     end 
        
    it "should register vm as a template if as template is true" do
        #Then
           mock_host=double('host_view')
          @fixture.provider.stub(:get_host_view).and_return(mock_host)
          @fixture.provider.stub(:get_template).and_return(@fixture.get_astemplate_true)
          @fixture.provider.stub(:vm_register_as_template)
            
          @fixture.provider.should_receive(:get_host_view)
          @fixture.provider.should_receive(:get_template)
          @fixture.provider.should_receive(:vm_register_as_template)
          
                    
          #When
          @fixture.provider.create
        end 
  
   
  it "should register vm not as a template if as template is false" do
          #Then
             mock_host=double('host_view')
            @fixture.provider.stub(:get_host_view).and_return(mock_host)
            @fixture.provider.stub(:get_template).and_return(@fixture.get_astemplate_false)
            @fixture.provider.stub(:vm_register)
              
            @fixture.provider.should_receive(:get_host_view)
            @fixture.provider.should_receive(:get_template)
            @fixture.provider.should_receive(:vm_register)
            
                      
            #When
            @fixture.provider.create
          end 
     end
   
  context "when vc_vm_register calls destroy " do
       it "should unregister vm if vm powered off" do
       #Then
            @fixture.provider.stub(:power_off_vm_unregister)
            @fixture.provider.vmObj.should_receive(:power_off_vm_unregister)
         
         #When
         @fixture.provider.destroy
       end 
          
     
     end
   
   
end