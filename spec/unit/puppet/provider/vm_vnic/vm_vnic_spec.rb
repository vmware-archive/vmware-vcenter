require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vm_vnic/vm_vnic_fixture'

describe "Create vm_snapshot behavior testing" do
  before(:each) do
    @fixture = Vm_vnic_fixture.new

  end

  context "when vm_vnic provider is created " do
    it "should have a create method defined for vm_vnic" do
      @fixture.provider.class.instance_method(:create).should_not == nil
    end

    it "should have a destroy method defined for vm_vnic" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have a exists? method defined for vm_vnic" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcenter'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

end