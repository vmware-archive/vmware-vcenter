# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
Puppet::Type.type(:esx_maintmode).provide(:esx_maintmode, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vsphere hosts entering and exiting maintenance mode."  

# Place the system into MM
 def create
	begin  
	host.EnterMaintenanceMode_Task(:timeout => resource[:timeout], 
     :evacuatePoweredOffVms => resource[:evacuate_powered_off_vms]).wait_for_completion
	rescue 
	puts 'Could not find Host system.Either Host is not exist or disconnected'
	end
end
 # Exit MM on the system
 def destroy 
	begin
	host.ExitMaintenanceMode_Task(:timeout => resource[:timeout]).wait_for_completion
	rescue 
	puts 'Could not find Host system.Either Host is not exist or disconnected'
	end
end
 def exists?
   begin
   host.runtime.inMaintenanceMode
   rescue 
   puts 'Host is not available'
	end
end

 private

 def host 
	begin
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
	rescue 
	puts 'Could not find Host system.Either Host is not exist or disconnected'
	end 
end
end