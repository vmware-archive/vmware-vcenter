# Copyright (C) 2013 VMware, Inc.
require 'set'

require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:esx_iscsi_targets).provide(:esx_iscsi_targets, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages iSCSI targets."

  def self.map
    @map ||= PuppetX::VMware::Mapper.new_map('HostInternetScsiHbaSendTargetMap')
  end

  def map
    self.class.map
  end

  map.leaf_list.each do |leaf|
    define_method(leaf.prop_name) do
      value = PuppetX::VMware::Mapper::munge_to_tfsyms.call(
        PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      )
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set(config_should, leaf.path_should, value)
      properties_rcvd.add leaf.prop_name
      properties_reqd.merge leaf.requires
      @flush_required = true
    end
  end

  def exists?
    send_target
  end

  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  def create
    @creating = true
    @create_message ||= []
    map.leaf_list.each do |leaf|
      p = leaf.prop_name
      unless (value = @resource[p]).nil?
        self.send("#{p}=".to_sym, value)
        @create_message << "#{leaf.full_name} => #{value.inspect}"
      end
    end

    esxhost.configManager.storageSystem.AddInternetScsiSendTargets(
      :iScsiHbaDevice => resource[:iscsi_hba_device], :targets => [flush_prep])
    @flush_required = false
  end

  def destroy
    target = [ send_target ]
    esxhost.configManager.storageSystem.RemoveInternetScsiSendTargets(
      :iScsiHbaDevice => resource[:iscsi_hba_device], :targets => target)
  end

  def flush_prep
    # To change some properties, the API requires others that may not have
    # changed. If not, they must be fetched from the type. When additional
    # properties are fetched, new items may be added to required_properties,
    # so iteration is required.
    Puppet.debug "requiring: #{@properties_rcvd.sort.inspect} were received"
    Puppet.debug "requiring: #{@properties_reqd.sort.inspect} initially required"
    properties_rcvd_old = Set.new
    while properties_rcvd != properties_rcvd_old
      properties_rcvd_old = properties_rcvd.dup
      properties_reqd.subtract properties_rcvd
      unless properties_reqd.empty?
        Puppet.debug "requiring: #{@properties_reqd.sort.inspect} are required"
        # properties_reqd may change
        # properties_rcvd will change unless resource has no value for property
        properties_reqd.dup.each{|p|
          self.send "#{p}=".to_sym, @resource[p] unless @resource[p].nil?
        }
      end
    end
    properties_reqd.subtract properties_rcvd
    Puppet.debug "requiring: #{@properties_rcvd.sort.inspect} were received"
    unless @properties_reqd.empty?
      fail "required properties missing - #{@properties_reqd.inspect}"
    end
    # create RbVmomi objects with properties in place of hashes with keys
    Puppet.debug "'is_now' is #{config_is_now.inspect}'}"
    Puppet.debug "'should' is #{config_should.inspect}'}"
    spec = map.objectify config_should
    Puppet.debug "'object' is #{spec.inspect}'}"
    spec
  end

  def flush
    # Property updates are not supported in this release
    #  Things get tricky here as there are 3 update methods depending on which
    #  attributes are changing
    return unless @flush_required
  end

  private

  def properties_rcvd
    @properties_rcvd ||= Set.new
  end

  # The required properties set.
  # Add items here if they MUST be present in the inputs.
  def properties_reqd
    @properties_reqd ||= Set.new()
  end

  def config_is_now
    @config_is_now ||= (@creating ? {} : map.annotate_is_now(send_target))
  end

  def config_should
    @config_should ||= {}
  end

  def esxhost
    @esxhost ||= vim.searchIndex.FindByDnsName(:dnsName => @resource[:esx_host],
      :vmSearch => false)
  end

  def hba
    @hba ||= esxhost.configManager.storageSystem.storageDeviceInfo.hostBusAdapter.find{|a|
      a.device == resource[:iscsi_hba_device]}
  end

  def send_target
    @send_target ||= hba.configuredSendTarget.find{|t| t.address == resource[:address]}
  end
end
