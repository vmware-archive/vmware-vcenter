# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_vswitch).provide(:esx_vswitch, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter vSwitch"
  #Create vSwitch method.
  def create
    Puppet.debug "Entered in create"
    create_vswitch
  end

  #Destroy vSwitch method.
  def destroy
    Puppet.debug "Entered in destroy"
    begin
      remove_vswitch
    rescue Exception => excep
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
      update_vswitch(value)
    rescue Exception => excep
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
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    raise Puppet:Error.new("No Host in datacenter #{walk_dc}") unless host

    if(host.configManager.networkSystem != nil)
      networksystem=host.configManager.networkSystem
    end

    if resource[:nics].length > 0
      hostbridge = RbVmomi::VIM::HostVirtualSwitchBondBridge(:nicDevice => resource[:nics])
    end

    vswitchspec = RbVmomi::VIM::HostVirtualSwitchSpec(:bridge => hostbridge, :numPorts => resource[:num_ports])
    networksystem.AddVirtualSwitch(:vswitchName => resource[:name], :spec => vswitchspec)
    Puppet.notice "Created vSwitch: #{resource[:name]}"
  end

  #update vSwitch
  def update_vswitch(value)
    Puppet.debug "Updating vSwitch"
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    raise Puppet:Error.new("No Host in datacenter #{walk_dc}") unless host
    networksystem=host.configManager.networkSystem

    if value.length > 0
      hostbridge = RbVmomi::VIM::HostVirtualSwitchBondBridge(:nicDevice => value)
      vswitchspec = RbVmomi::VIM::HostVirtualSwitchSpec(:bridge => hostbridge, :numPorts => resource[:num_ports])
    else
      vswitchspec = RbVmomi::VIM::HostVirtualSwitchSpec(:bridge => nil, :numPorts => resource[:num_ports])
    end

    networksystem.UpdateVirtualSwitch(:vswitchName => resource[:name], :spec => vswitchspec)
    Puppet.notice "Updated vSwitch: #{resource[:name]}"
  end

  #find vSwitch
  def find_vswitch
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    networksystem=host.configManager.networkSystem
    vswitches = networksystem.networkInfo.vswitch

    for vswitch in (vswitches) do
      availablevswitch = vswitch.name
      if (availablevswitch == resource[:name])
        return true
      end
    end
    #return false if vswitch not found
    return false
  end

  #retrieve pnics associated with vSwitch
  def retrieve_vswitch_pnic_objects
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    networksystem=host.configManager.networkSystem
    vswitches = networksystem.networkConfig.vswitch
    for vswitch in (vswitches) do
      availablevswitch = vswitch.name
      if (availablevswitch == resource[:name])
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
    host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    networksystem=host.configManager.networkSystem
    networksystem.RemoveVirtualSwitch(:vswitchName => resource[:name])

    Puppet.notice "Removed vSwitch: #{resource[:name]}"
  end

end
