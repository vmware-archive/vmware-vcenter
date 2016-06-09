require 'spec_helper'

describe Puppet::Type.type(:vc_dvswitch_pool) do
  parameters = [ :name, :dvswitch_path, :dvswitch_name, :key ]
  properties = [ :description, :limit, :priority_tag, :shares, :level ]

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
