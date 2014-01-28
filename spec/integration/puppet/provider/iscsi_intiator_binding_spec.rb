#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:iscsi_intiator_binding).provider(:iscsi_intiator_binding) do

  integration_yml =  File.join(provider_path, '/fixtures/integration/integration.yml')
  iscsi_intiator_binding_yml = YAML.load_file(integration_yml)  
  initiator_binding = iscsi_intiator_binding_yml['initiator_binding']

  transport_yml =  File.join(provider_path, '/fixtures/integration/transport.yml')
  transport_yml = YAML.load_file(transport_yml)
  transport_node = transport_yml['transport']

  let(:bind_iscsi_initiator) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:iscsi_intiator_binding).new(
    :name                   => initiator_binding['name'],
    :ensure                 => initiator_binding['ensure'],
    :transport              => transport,
    :catalog                => @catalog,
    :vmknics                => initiator_binding['vmknics'],
    :script_executable_path => initiator_binding['script_executable_path'],
    :host_username          => initiator_binding['host_username'],
    :host_password          => initiator_binding['host_password']
    )
  end

  initiator_unbinding = iscsi_intiator_binding_yml['initiator_unbinding']

  let(:unbind_iscsi_initiator) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:iscsi_intiator_binding).new(
    :name                   => initiator_unbinding['name'],
    :ensure                 => initiator_unbinding['ensure'],
    :transport              => transport,
    :catalog                => @catalog,
    :vmknics                => initiator_unbinding['vmknics'],
    :script_executable_path => initiator_unbinding['script_executable_path'],
    :host_username          => initiator_unbinding['host_username'],
    :host_password          => initiator_unbinding['host_password']
    )
  end

  let(:provider) do
    described_class.new( )
  end

  describe "when binding a iscsi initiator" do
    it ", iscsi binding should exist before initiating destroy operation" do
      response = bind_iscsi_initiator.provider.is_binded
      response.should be_false
    end

    it ", should be able bind iscsi initiator" do
      bind_iscsi_initiator.provider.create
      response = bind_iscsi_initiator.provider.is_binded
      response.should be_true
    end
  end

  describe "when undinding a iscsi initiator - which already bind" do
    it ", iscsi binding should exist before initiating destroy operation" do
      response = bind_iscsi_initiator.provider.is_binded
      response.should be_true
    end
    it ", should be able to unbind iscsi initiator " do

      unbind_iscsi_initiator.provider.destroy
      response = unbind_iscsi_initiator.provider.is_binded
      response.should be_false
    end
  end

end
