require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vc_vm/vc_vm_fixture'

describe "vm create and clone behavior testing" do
  before(:each) do
    @fixture = Vc_vm_fixture.new
    @fixture.provider.stub(:create_vm)
    @fixture.provider.stub(:clone_vm)
    @fixture.provider.stub(:delete_vm)
    @fixture.provider.stub(:check_vm)
  end

  context "when vc_vm provider is created " do
    it "should have a create method defined for vc_vm" do
      @fixture.provider.class.instance_method(:create).should_not == nil
    end

    it "should have a destroy method defined for vc_vm" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have a exists? method defined for vc_vm" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcentre'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when vc_vm is created " do
    it "should create vm  if value of operation is create" do
      #Then
      @fixture.provider.stub(:get_operation_name).and_return('create')
      @fixture.provider.should_receive(:get_operation_name)
      @fixture.provider.should_receive(:create_vm)

      #When
      @fixture.provider.create
    end

    it "should clone vm  if value of operation is clone" do
      #Then
      @fixture.provider.stub(:get_operation_name).and_return('clone')
      @fixture.provider.should_receive(:get_operation_name)
      @fixture.provider.should_receive(:clone_vm)

      #When
      @fixture.provider.create
    end
  end

  context "when vc_vm calls destroy " do
    it "should delete vm " do
      #Then
      @fixture.provider.stub(:get_vm_from_datacenter).and_return("VM")
      @fixture.provider.stub(:get_power_state).and_return("poweredOff")
      @fixture.provider.should_receive(:get_vm_from_datacenter)
      @fixture.provider.should_receive(:get_power_state)
      @fixture.provider.should_receive(:delete_vm)

      #When
      @fixture.provider.destroy
    end

    it "should receive error if vm not exist" do
      #Then
      @fixture.provider.stub(:get_vm_from_datacenter).and_return(nil)
      @fixture.provider.stub(:get_power_state).and_return("poweredOff")
      @fixture.provider.should_receive(:get_vm_from_datacenter)
      Puppet.should_receive(:err)
      #When
      @fixture.provider.destroy
    end
    it "should receive notice if vm exist and state is powered off/suspended " do
      #Then
      @fixture.provider.stub(:get_vm_from_datacenter).and_return("VM")
      @fixture.provider.stub(:get_power_state).and_return("poweredOff")
      @fixture.provider.should_receive(:get_vm_from_datacenter)
      @fixture.provider.should_receive(:get_power_state)
      Puppet.should_receive(:notice)

      #When
      @fixture.provider.destroy
    end

  end

end