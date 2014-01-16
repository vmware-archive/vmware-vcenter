#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:esx_get_iqns).provider(:esx_get_iqns) do
  esx_get_iqns_yml =  YAML.load_file(my_fixture('esx_get_iqns.yml'))
  getiqns = esx_get_iqns_yml['getiqns']

  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']

  let(:esx_get_iqn) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:esx_get_iqns).new(
    :host               => getiqns['host'],
    :transport          => transport,
    :catalog            => @catalog,
    :hostusername       => getiqns['hostusername'],
    :hostpassword      => getiqns['hostpassword']
    )
  end

  describe "when getting iqns from server" do
    it "should be able to get iqns" do
      expect {  esx_get_iqn.provider.get_esx_iqns}.to_not raise_error       
    end
  end
end