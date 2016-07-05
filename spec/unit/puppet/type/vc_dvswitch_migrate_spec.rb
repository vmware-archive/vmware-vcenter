require 'spec_helper'

describe Puppet::Type.type(:vc_dvswitch_migrate) do
  parameters = [ :name, :host, :dvswitch ]
  
  properties = [ ]

  (0..3).each do |i|
    properties << "vmk#{i}".to_sym
    properties << "vmnic#{i}".to_sym
  end

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
