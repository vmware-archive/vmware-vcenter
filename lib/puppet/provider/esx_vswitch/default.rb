# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_vswitch).provide(:esx_vswitch, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter vSwitch"

  #Create vSwitch method.
  def create
    Puppet.debug "Entered in create"
    begin
      create_vswitch
    rescue Exception => excep
      Puppet.err "Unable to create vSwitch because the following exception occurred: -"
      Puppet.err excep.message
    end
  end

  #Destroy vSwitch method.
  def destroy
    Puppet.debug "Entered in destroy"
    begin
      remove_vswitch
    rescue Exception => excep
      Puppet.err "Unable to remove vSwitch because the following exception occurred: - "
      Puppet.err excep.message
    end
  end

  #Check for existence of vSwitch
  def exists?
    Puppet.debug "Entered in exists?"
    find_vswitch == true
  end

  #Getter method for nics property
  def nics
    Puppet.debug "Retreiving nics associated with vSwitch"
    begin
      retrieve_vswitch_pnic_objects
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

  #Setter method for nics property
  def nics=(value)
    Puppet.debug "Updating nics associated with vSwitch"
    begin
      if value != nil and value.length > 0
        hostbridge = RbVmomi::VIM::HostVirtualSwitchBondBridge(:nicDevice => value)
        vswitchspec = RbVmomi::VIM::HostVirtualSwitchSpec(:bridge => hostbridge, :numPorts => resource[:num_ports])
      else
        vswitchspec = RbVmomi::VIM::HostVirtualSwitchSpec(:bridge => nil, :numPorts => resource[:num_ports])
      end
      update_vswitch(vswitchspec)
    rescue Exception => excep
      Puppet.err "Unable to configure nics on vSwitch because the following exception occurred: - "
      Puppet.err excep.message
    end
  end

  #Getter method for num_ports property
  def num_ports
    Puppet.debug "Retreiving num_ports associated with vSwitch"
    begin
      retreive_numports
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

  #Setter method for num_ports property
  def num_ports=(value)
    Puppet.debug "Updating num_ports associated with vSwitch"
    begin
      actualspec = retrieve_vswitch_spec
      actualspec.numPorts = value
      update_vswitch(actualspec)
    rescue Exception => excep
      Puppet.err "Unable to set the num_ports on vSwitch because the following exception occurred: - "
      Puppet.err excep.message
    end
  end

  #Setter method for nicorderpolicy
  def nicorderpolicy=(value)
    Puppet.debug "Updating nicorderpolicy associated with vSwitch"
    begin
      activenic = nil
      standbynic = nil
      if(value['activenic'] != nil and value['activenic'].length > 0)
        activenic = value['activenic']
      end
      if(value['standbynic'] != nil and value['standbynic'].length > 0)
        standbynic = value['standbynic']
      end
      hostnicorderpolicy = RbVmomi::VIM::HostNicOrderPolicy(:activeNic => activenic, :standbyNic => standbynic)
      actualspec = retrieve_vswitch_spec
      actualspec.policy.nicTeaming.nicOrder = hostnicorderpolicy
      update_vswitch(actualspec)
    rescue Exception => excep
      Puppet.err "Unable to configure nicorderpolicy on vSwitch because the following exception occurred: - "
      Puppet.err excep.message
    end
  end

  #Getter method for nicorderpolicy
  def nicorderpolicy
    Puppet.debug "Retreiving nicorderpolicy associated with vSwitch"
    begin
      existing_activenic = retrieve_vswitch_nicorder_policy.activeNic
      existing_standbynic = retrieve_vswitch_nicorder_policy.standbyNic
      {"activenic" => existing_activenic, "standbynic" => existing_standbynic}
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

  #Setter methid for mtu
  def mtu=(value)
    Puppet.debug "Updating MTU associated with vSwitch"
    begin
      actualspec = retrieve_vswitch_spec
      actualspec.mtu = value
      update_vswitch(actualspec)
    rescue Exception => excep
      Puppet.err "Unable to set mtu on vSwitch because the following exception occurred: - "
      Puppet.err excep.message
    end
  end

  #Getter methid for mtu
  def mtu
    Puppet.debug "Retrieving MTU associated with vSwitch"
    begin
      retrieve_vswitch_mtu
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

  #Getter methid for checkbeacon in network failover detection
  def checkbeacon
    Puppet.debug "Retrieving checkbeacon flag associated with vSwitch"
    begin
      retreive_checkbeacon
    rescue Exception => excep
      Puppet.err excep.message
    end
  end

  #Setter methid for checkbeacon in network failover detection
  def checkbeacon=(value)
    Puppet.debug "Updating checkbeacon flag associated with vSwitch"
    begin
      actualspec = retrieve_vswitch_spec
      actualspec.policy.nicTeaming.failureCriteria.checkBeacon = value
      update_vswitch(actualspec)
    rescue Exception => excep
      Puppet.err "Unable to configure checkbeacon on vSwitch because the following exception occurred: - "
      Puppet.err excep.message
    end
  end

  private

  #traverse dc
  def walk_dc(path=resource[:path])
    datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "No datacenter in path: #{path}") unless datacenter
    datacenter
  end

  #create vSwitch
  def create_vswitch
    Puppet.debug "Creating vSwitch"
    host = retrieve_host

    if(host.configManager.networkSystem != nil)
      networksystem=host.configManager.networkSystem
    else
      raise Puppet::Error.new("Error retrieving network configuration of host: #{host}")
    end

    #creating vSwitchspec if there are nic device to be attached with vSwitch
    if resource[:nics] != nil and resource[:nics].length > 0
      hostbridge = RbVmomi::VIM::HostVirtualSwitchBondBridge(:nicDevice => resource[:nics])
    end

    vswitchspec = RbVmomi::VIM::HostVirtualSwitchSpec(:bridge => hostbridge, :mtu => resource[:mtu], :numPorts => resource[:num_ports])

    #add vSwitch to the host
    networksystem.AddVirtualSwitch(:vswitchName => resource[:vswitch], :spec => vswitchspec)

    activenic = nil
    standbynic = nil
    if(resource[:nicorderpolicy ] != nil)
      nicorderpolicy = resource[:nicorderpolicy ]
      if(nicorderpolicy ['activenic'] != nil and nicorderpolicy ['activenic'].length > 0)
        activenic = nicorderpolicy ['activenic']
      end
      if(nicorderpolicy ['standbynic'] != nil and nicorderpolicy ['standbynic'].length > 0)
        standbynic = nicorderpolicy ['standbynic']
      end
    end

    #create NicOrderPolicy so as to configure nic teaming
    hostnicorderpolicy = RbVmomi::VIM::HostNicOrderPolicy(:activeNic => activenic, :standbyNic => standbynic)
    actualspec = retrieve_vswitch_spec
    actualspec.policy.nicTeaming.nicOrder = hostnicorderpolicy

    #create data to configure network failover detection in nic teaming policy
    if(resource[:checkbeacon] != nil)
      actualspec.policy.nicTeaming.failureCriteria.checkBeacon = resource[:checkbeacon]
    end

    #update vSwitch with nic teaming policy spec
    update_vswitch(actualspec)

    Puppet.notice "Created vSwitch: #{resource[:vswitch]}"
  end

  #update vSwitch
  def update_vswitch(vswitchspec)
    Puppet.debug "Updating vSwitch"
    host = retrieve_host
    networksystem=host.configManager.networkSystem

    networksystem.UpdateVirtualSwitch(:vswitchName => resource[:vswitch], :spec => vswitchspec)
    Puppet.notice "Updated vSwitch: #{resource[:vswitch]}"
  end

  #find vSwitch
  def find_vswitch
    host = retrieve_host

    networksystem=host.configManager.networkSystem
    vswitches = networksystem.networkInfo.vswitch

    vswitches.each do |vswitch|
      availablevswitch = vswitch.name
      if (availablevswitch == resource[:vswitch])
        return true
      end
    end
    #return false if vswitch not found
    return false
  end

  #retrieve pnics associated with vSwitch
  def retrieve_vswitch_pnic_objects
    host = retrieve_host
    networksystem=host.configManager.networkSystem
    vswitches = networksystem.networkConfig.vswitch
    vswitches.each do |vswitch|
      availablevswitch = vswitch.name
      if (availablevswitch == resource[:vswitch])
        if vswitch.spec.bridge != nil and vswitch.spec.bridge.nicDevice != nil
          return vswitch.spec.bridge.nicDevice
        end
        return nil
      end
    end
  end

  #remove vSwitch
  def remove_vswitch
    Puppet.debug "Destroying vSwitch"
    host = retrieve_host
    networksystem=host.configManager.networkSystem
    networksystem.RemoveVirtualSwitch(:vswitchName => resource[:vswitch])

    Puppet.notice "Removed vSwitch: #{resource[:vswitch]}"
  end

  #retrieve vSwitch specifications
  def retrieve_vswitch_spec
    host = retrieve_host
    networksystem = host.configManager.networkSystem
    vswitches = networksystem.networkInfo.vswitch
    actual = nil
    vswitches.each do |vswitch|
      availablevswitch = vswitch.name
      if (availablevswitch == resource[:vswitch])
        return vswitch.spec
      end
    end
  end

  #retreive vSwitch nicorder policy
  def retrieve_vswitch_nicorder_policy
    vswitchspec = retrieve_vswitch_spec
    return vswitchspec.policy.nicTeaming.nicOrder
  end

  #retreive vSwitch MTU valuel
  def retrieve_vswitch_mtu
    vswitchspec = retrieve_vswitch_spec
    return vswitchspec.mtu
  end

  #retreive vSwitch checkbeacon flag value
  def retreive_checkbeacon
    vswitchspec = retrieve_vswitch_spec
    return vswitchspec.policy.nicTeaming.failureCriteria.checkBeacon.to_s
  end

  #retreive vSwitch num_ports value
  def retreive_numports
    vswitchspec = retrieve_vswitch_spec
    return vswitchspec.numPorts
  end

  #retreive host given the host IP or name
  def retrieve_host
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    raise Puppet::Error.new("An invalid host name or IP address is entered. Enter the correct host name and IP address.") unless host
    return host
  end

end
