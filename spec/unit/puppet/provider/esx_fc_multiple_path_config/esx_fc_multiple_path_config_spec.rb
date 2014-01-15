require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_fc_multiple_path_config/esx_fc_multiple_path_config_fixture'

describe "Create esx_fc_multiple_path_config behavior testing" do
  before(:each) do
    @fixture = Esx_fc_multiple_path_config_fixture.new

  end

  context "when esx_fc_multiple_path_config provider is created " do
    it "should have a create method defined for esx_fc_multiple_path_config" do
      @fixture.provider.class.instance_method(:create).should_not == nil
    end

    it "should have a destroy method defined for esx_fc_multiple_path_config" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have a exists? method defined for esx_fc_multiple_path_config" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcenter'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when esx_fc_multiple_path_config is created " do
    it "should configure esx_fc_multiple_path_config" do
      #Then
      @fixture.provider.stub(:host).and_return("test")
      @fixture.provider.should_receive(:change_policy)

      #When
      @fixture.provider.create
    end
  end

end