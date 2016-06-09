require 'spec_helper'

describe Puppet::Type.type(:vc_host) do
  parameters = [ :name, :username, :password, :sslthumbprint, :secure ]
  properties = [ :path ]

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
end
