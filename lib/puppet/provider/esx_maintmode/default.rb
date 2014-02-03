# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_maintmode).provide(:esx_maintmode, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vsphere hosts entering and exiting maintenance mode."
  def enterMaintenanceMode
    host.EnterMaintenanceMode_Task(:timeout => resource[:timeout],
    :evacuatePoweredOffVms => resource[:evacuate_powered_off_vms]).wait_for_completion
  end

  def exitMaintenanceMode
    host.ExitMaintenanceMode_Task(:timeout => resource[:timeout]).wait_for_completion
  end

  # Place the system into MM
  def create
    begin
      enterMaintenanceMode
    rescue
      Puppet.err 'Could not find Host system.Either Host is not exist or disconnected'
    end
  end

  # Exit MM on the system
  def destroy
    begin
      exitMaintenanceMode
    rescue
      Puppet.err 'Could not find Host system.Either Host is not exist or disconnected'
    end
  end

  def exists?
    begin
      host.runtime.inMaintenanceMode
    rescue
      Puppet.err 'Host is not available'
    end
  end

  private

  def host
    begin
      @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
    rescue
      Puppet.err 'Could not find Host system.Either Host is not exist or disconnected'
    end
  end
end
