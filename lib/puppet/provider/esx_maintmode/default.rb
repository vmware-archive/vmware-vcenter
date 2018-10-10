# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_maintmode).provide(:esx_maintmode, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vsphere hosts entering and exiting maintenance mode."
  def enterMaintenanceMode
    if resource[:check_disconnected_state] && host.summary.runtime.connectionState != 'connected'
      Puppet.debug("Server is not in connected state. Maintenance mode operation is skipped")
      return true
    end

    if resource[:vsan_action].nil?
      host.EnterMaintenanceMode_Task(:timeout => resource[:timeout],
                                     :evacuatePoweredOffVms => resource[:evacuate_powered_off_vms]).wait_for_completion
    else
      Puppet.debug("VSAN action specified = %s" % resource[:vsan_action])
      decommissionmode = RbVmomi::VIM::VsanHostDecommissionMode.new
      decommissionmode.objectAction = resource[:vsan_action]
      hostmaintspec = RbVmomi::VIM::HostMaintenanceSpec.new
      hostmaintspec.vsanMode = decommissionmode
      host.EnterMaintenanceMode_Task(:timeout => resource[:timeout],
                                     :evacuatePoweredOffVms => resource[:evacuate_powered_off_vms],
                                     :maintenanceSpec => hostmaintspec).wait_for_completion
    end

  end

  def exitMaintenanceMode
    host.ExitMaintenanceMode_Task(:timeout => resource[:timeout]).wait_for_completion
  end

  # Place the system into MM
  def create
    begin
      enterMaintenanceMode
    rescue Exception => e
      fail "Could not enter maintenance mode because the following exception occured: -\n #{e.message}"
    end
  end

  # Exit MM on the system
  def destroy
    begin
      exitMaintenanceMode
    rescue Exception => e
      fail "Could not exit maintenance mode because the following exception occurred: -\n #{e.message}" 
    end
  end

  def exists?
    begin
      host.runtime.inMaintenanceMode
    rescue => e
      msg = "Could not determine maintenance mode state: %s" % e.message
      if resource[:fail_when_undetermined]
        fail msg
      else
        # If the flag is set to not fail when we cannot determine maintenance mode,
        # we simply return value to prevent create/destroy to get invoked
        Puppet.warning(msg)
        resource[:ensure] == :present
      end
    end
  end

end
