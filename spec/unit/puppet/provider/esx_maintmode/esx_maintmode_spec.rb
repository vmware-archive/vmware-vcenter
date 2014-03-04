require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rspec/mocks'
require 'fixtures/unit/puppet/provider/esx_maintmode/esx_maintmode_fixture'

describe "Unit tests - vsphere hosts entering and exiting maintenance mode" do
  before(:each) do
    @fixture = Esx_maintmode_fixture.new 

  end

  context "when esx_maintmode provider is created " do
    it "should have a create method defined for esx_maintmode" do
      @fixture.provider.class.instance_method(:create).should_not == nil
    end

    it "should have a destroy method defined for esx_maintmode" do
      @fixture.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have a exists? method defined for esx_maintmode" do
      @fixture.provider.class.instance_method(:exists?).should_not == nil
    end

    it "should have a parent 'Puppet::Provider::Vcentre'" do
      @fixture.provider.should be_kind_of(Puppet::Provider::Vcenter)
    end
  end

  
  context "when create is called on esx_maintmode" do
    it "should call enterMaintenanceMode - if there is no error exception should not be raised" do
      #Then
      @fixture.provider.stub(:enterMaintenanceMode)      
	  expect { @fixture.provider.should_receive(:enterMaintenanceMode) }.to_not raise_error
      #When
      @fixture.provider.create
    end
	
	# it "should call enterMaintenanceMode - if there is error exception should be raised" do
      #Then
      # @fixture.provider.stub(:enterMaintenanceMode).      
	  # expect { @fixture.provider.should_receive(:enterMaintenanceMode) }.to_not raise_error
      #When
      # @fixture.provider.create
    # end

    #    it "should do nothing if host is not present" do
    #        #Then
    #          ##TODO
    #
    #          #When
    #          @fixture.provider.create
    #        end
    #
    #    it "should do nothing if host already in maintenance mode" do
    #            #Then
    #                ##TODO
    #              #When
    #              @fixture.provider.create
    #            end
    end

    context "when destroy is called on esx_maintmode" do
      it "if host exists and is in maintenance mode it should exit it from maintenance mode" do
        #Then
        @fixture.provider.stub(:exitMaintenanceMode)        
		expect { @fixture.provider.should_receive(:exitMaintenanceMode) }.to_not raise_error
        #When
        @fixture.provider.destroy
      end

      #      it "if host does not exist nothing should be done" do
      #          #Then
      #            ##TODO
      #
      #            #When
      #        @fixture.provider.destroy
      #          end
      #
      #    it "if host is not in maintenance mode nothing should be done" do
      #             #Then
      #               ##TODO
      #
      #               #When
      #           @fixture.provider.destroy
      #       end
    end

  
end