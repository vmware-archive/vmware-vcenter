require 'spec_helper'

describe Puppet::Type.type(:esx_dnsconfig) do
  parameters = [ :host ]
  properties = [ :dhcp, :host_name, :domain_name, :search_domain ]

  parameters.each do |parameter|
    it "should have a #{parameter} parameter" do
      expect(described_class.attrclass(parameter).ancestors).to be_include(Puppet::Parameter)
    end
  end

  properties.each do |property|
    it "should have a #{property} property" do
      expect(described_class.attrclass(property).ancestors).to be_include(Puppet::Property)
    end
  end

  it "should not allow dhcp false" do
    expect {
      described_class.new(:name => "test", :dhcp => :true)
    }.to raise_error(/This resource only allows disabling dhcp./)
  end

end
