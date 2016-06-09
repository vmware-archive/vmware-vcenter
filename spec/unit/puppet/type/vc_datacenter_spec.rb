require 'spec_helper'

describe Puppet::Type.type(:vc_datacenter) do
  parameters = [ :path ]

  parameters.each do |parameter|
    it "should have a #{parameter} parameter" do
      expect(described_class.attrclass(parameter).ancestors).to be_include(Puppet::Parameter)
    end
  end

end
