require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vc_vm/vc_vm_fixture'

describe "vm create and clone behavior testing" do
  before(:each) do
    @fixture = Vc_vm_fixture.new
    @fixture.provider.stubs(:create_vm)
    @fixture.provider.stubs(:clone_vm)
    @fixture.provider.stubs(:delete_vm)
    @fixture.provider.stubs(:check_vm)
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
    before(:each) do
      @fixture.provider.expects(:vm).at_least_once.returns(nil).returns(mock("vm_object"))
      @fixture.provider.expects(:cdrom_iso).returns(mock("cdrom_object"))
      @fixture.provider.expects(:configure_iso)
    end

    it "should create vm  if value of operation is create" do
      @fixture.provider.expects(:create_vm)

      @fixture.provider.create
    end

    it "should clone vm  if value of operation is clone" do
      @fixture.provider.resource[:template] = "mock_template"
      @fixture.provider.expects(:clone_vm)

      @fixture.provider.create
    end
  end

  context "when vc_vm calls destroy " do
    let(:destroy_task) {mock("destroy_task")}

    before(:each) do
      @fixture.provider.stubs(:power_state).returns("poweredOff")
      @fixture.provider.stubs(:cdrom_iso)
      @fixture.provider.stubs(:nfs_vm_datastore)
    end

    it "should delete vm " do
      @fixture.provider.stubs(:vm).returns(mock(:Destroy_Task => destroy_task))

      destroy_task.expects(:wait_for_completion)

      @fixture.provider.destroy
    end

    it "should receive error if vm not exist" do
      @fixture.provider.stubs(:vm)

      expect {@fixture.provider.destroy}.to raise_error(/undefined method `Destroy_Task' for nil/)
    end
  end
end
