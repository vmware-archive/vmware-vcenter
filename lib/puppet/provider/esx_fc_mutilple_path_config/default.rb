# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_fc_mutilple_path_config).provide(:esx_fc_mutilple_path_config, :parent => Puppet::Provider::Vcenter) do
  @doc = "FC / FCoE Storage multi-pathing configuration (Fixed / Round-Robin)"

  def create
   begin 
     if host == nil
       raise Puppet::Error, "Unable to find the host because host does not exists."
     else	
       change_policy
     end   
    rescue Exception => ex
        Puppet.err "Unable to perform the operation because the following exception occurred." 
        Puppet.err ex.message
   end    
  end

    def change_policy
    begin
		isPolicyApplied = false
		device_arr = host.configManager.storageSystem.storageDeviceInfo.multipathInfo.lun
		if device_arr == nil
			raise Puppet::Error, "Unable to find any native mutilpath storage devices on the given host #{host}."
		else
			device_arr.each do |change_policy|
				if change_policy.path.length > 1 
					Puppet.notice "Changing the multipath policy to #{resource[:policyname]} of FC/FCoE deviceID #{change_policy.id}"					
					policySpec = RbVmomi::VIM::HostMultipathInfoFixedLogicalUnitPolicy(:policy => resource[:policyname], :prefer => "*")
					host.configManager.storageSystem.SetMultipathLunPolicy(:lunId => change_policy.id , :policy => policySpec)
					isPolicyApplied = true			
				end
			end
		end
		if isPolicyApplied == false
			raise Puppet::Error, "Unable to find any FC/FCoe device for multipath policy changes."
		end
	end
    rescue Exception => ex
        Puppet.err "Unable to change the policy to #{resource[:policyname]} because the following exception occurred."
        Puppet.err ex.message
	end

  def exists?
      return false
  end
  
  def destroy
  end   
    
private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
  end
end

