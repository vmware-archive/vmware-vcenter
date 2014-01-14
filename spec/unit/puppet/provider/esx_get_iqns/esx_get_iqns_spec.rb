require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_get_iqns/esx_get_iqns_fixture'

describe "Get iqns operation testing for esx" do
  before(:each) do
    @fixture = Esx_get_iqns_fixture.new
    @fixture.provider.stub(:get_iqn)
  end

  context "when esx_get_iqns provider is executed " do
    it "should have a get_esx_iqns method defined for esx_get_iqns" do
      @fixture.provider.class.instance_method(:get_esx_iqns).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcentre'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  context "when esx_get_iqns is created " do
    it "should return list of iqns" do
      #Then
      list = Array.new
      @fixture.provider.stub(:get_iqn_from_host).and_return(list)
      @fixture.provider.should_receive(:get_iqn_from_host)
      @fixture.provider.should_receive(:get_iqn).once.with(list).ordered
      #When
      @fixture.provider.get_esx_iqns
    end

    it "should not return iqns if host does not have hbas" do
      #Then
      @fixture.provider.stub(:get_iqn_from_host).and_return(nil)
      @fixture.provider.should_receive(:get_iqn_from_host)
	  @fixture.provider.should_not_receive(:get_iqn)
      Puppet.should_receive(:err).twice

      #When
      @fixture.provider.get_esx_iqns
    end
  end

 

end