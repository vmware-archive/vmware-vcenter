require 'spec_helper'

describe Puppet::Type.type(:esx_iscsi) do
  parameters = [ :esx_host ]

  parameters.each do |parameter|
    it "should have a #{parameter} parameter" do
      expect(described_class.attrclass(parameter).ancestors).to be_include(Puppet::Parameter)
    end
  end

end
