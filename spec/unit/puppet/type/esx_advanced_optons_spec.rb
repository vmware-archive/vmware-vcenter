require 'spec_helper'

describe Puppet::Type.type(:esx_advanced_options) do
  parameters = [ :host ]
  properties = [ :options ]

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

  context "when initialized with options" do
    let(:resource) {
      options = {
        "integer.option" => 1001,
        "string.option" =>  "1002",
        "boolean.option" => true,
      }
      described_class.new(:name => 'esxihost', :options => options)
    }

    it "should change integers to strings" do
      expect(resource[:options]["integer.option"]).to be_a(String)
    end

    it "should not change booleans" do
      expect(resource[:options]["boolean.option"]).to eq(true)
    end

  end

end
