require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_vswitch/esx_vswitch_fixture'

describe "Create vSwitch behavior testing" do
  before(:each) do
    @fixture = Esx_vswitch_fixture.new

  end

  context "when esx_vswitch provider is created " do
    it "should have a create method defined for esx_vswitch" do
      @fixture.provider.class.instance_method(:create).should_not == nil
    end

    it "should have a destroy method defined for esx_vswitch" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have a exists? method defined for esx_vswitch" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcenter'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when esx_vswitch is created " do
    it "should create vSwitch" do
      #Then
      @fixture.provider.should_receive(:create_vswitch)

      #When
      @fixture.provider.create
    end
  end

  context "when esx_vswitch is destroyed " do
    it "should destroy vSwitch" do
      #Then
      @fixture.provider.should_receive(:remove_vswitch)

      #When
      @fixture.provider.destroy
    end
  end

  context "when esx_vswitch is checked for existence " do
    it "should check its existence" do
      #Then
      @fixture.provider.should_receive(:find_vswitch)

      #When
      @fixture.provider.exists?
    end
  end

end