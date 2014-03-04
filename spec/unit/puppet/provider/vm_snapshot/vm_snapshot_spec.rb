require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/vm_snapshot/vm_snapshot_fixture'

describe "Create vm_snapshot behavior testing" do
  before(:each) do
    @fixture = Vm_snapshot_fixture.new

  end

  context "when vm_snapshot provider is created " do
    it "should have a exists? method defined for vm_snapshot" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcenter'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

end