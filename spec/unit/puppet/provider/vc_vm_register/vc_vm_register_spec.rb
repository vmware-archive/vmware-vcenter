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
      @fixture.provider.expects(:get_host_view)

      @fixture.provider.expects(:get_template).never

      expect {@fixture.provider.create}.to raise_error(Puppet::Error, /Unable to find the host it is either invalid or does not exist./)
    end

    it "should register vm as a template if as template is true" do
      @fixture.provider.expects(:get_host_view).returns(Object.new)
      @fixture.provider.expects(:get_template).returns(@fixture.get_astemplate_true)
      @fixture.provider.expects(:vm_register_as_template)

      @fixture.provider.create
    end


    it "should register vm not as a template if as template is false" do
      #Then
      @fixture.provider.expects(:get_host_view).returns(Object.new)
      @fixture.provider.expects(:get_template).returns(@fixture.get_astemplate_false)
      @fixture.provider.expects(:vm_register)

      #When
      @fixture.provider.create
    end
  end

  context "when vc_vm_register calls destroy " do
    it "should unregister vm if vm powered off" do
      #Then
      @fixture.provider.stubs(:power_off_vm_unregister)
      @fixture.provider.expects(:power_off_vm_unregister).never

      #When
      @fixture.provider.destroy
    end
  end
end