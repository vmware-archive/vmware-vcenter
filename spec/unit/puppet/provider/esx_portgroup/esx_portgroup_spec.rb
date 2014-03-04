require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_portgroup/esx_portgroup_fixture'

describe "Create portgroup behavior testing" do
  before(:each) do
    @fixture = Esx_portgroup_fixture.new

  end

  context "when esx_portgroup provider is created " do
    it "should have a create method defined for esx_portgroup" do
      @fixture.provider.class.instance_method(:create).should_not == nil
    end

    it "should have a destroy method defined for esx_portgroup" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have a exists? method defined for esx_portgroup" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcenter'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when esx_portgroup is created " do
    it "should create esx_portgroup" do
      #Then
      @fixture.provider.should_receive(:create_port_group)

      #When
      @fixture.provider.create
    end
  end

  context "when esx_portgroup is destroyed " do
    it "should destroy esx_portgroup" do
      #Then
      @fixture.provider.should_receive(:remove_port_group)

      #When
      @fixture.provider.destroy
    end
  end

  context "when esx_portgroup is checked for existence " do
    it "should check its existence" do
      #Then
      @fixture.provider.should_receive(:check_portgroup_existance)

      #When
      @fixture.provider.exists?
    end
  end

end