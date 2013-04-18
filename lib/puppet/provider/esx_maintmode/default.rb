# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_maintmode).provide(:esx_maintmode, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vsphere hosts entering and exiting maintenance mode."

  # Place the system into MM
  def create
    host.EnterMaintenanceMode_Task(:timeout => resource[:timeout], 
      :evacuatePoweredOffVms => resource[:evacuate_powered_off_vms]).wait_for_completion
  end

  # Exit MM on the system
  def destroy
    host.ExitMaintenanceMode_Task(:timeout => resource[:timeout]).wait_for_completion
  end

  def exists?
    host.runtime.inMaintenanceMode
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end
