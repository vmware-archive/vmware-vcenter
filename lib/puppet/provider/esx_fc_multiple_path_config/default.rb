# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_fc_multiple_path_config).provide(:esx_fc_multiple_path_config, :parent => Puppet::Provider::Vcenter) do
  @doc = "FC / FCoE Storage multi-pathing configuration (Fixed / Round-Robin)"
  def create
    begin
      if host == nil
        raise Puppet::Error, "An invalid host name or IP address is entered. Enter the correct host name and IP address."
      else
        change_policy
      end
    rescue Exception => ex
      Puppet.err "Unable to perform the operation because an unknown exception occurred. Verify the troubleshooting logs. If the issue persists, contact your service provider."
      Puppet.err ex.message
    end
  end

  def change_policy
    begin
      isPolicyApplied = false
      device_arr = host.configManager.storageSystem.storageDeviceInfo.multipathInfo.lun
      if device_arr == nil
        raise Puppet::Error, "Unable to find any native multipath storage resources on the specified host #{host}."
      else	 
        device_arr.each do |change_policy|		
			paths = change_policy.path		
			paths.each do |path|			   			
				if ((path.transport.class.to_s.strip == 'HostFibreChannelTargetTransport') || (path.transport.class.to_s.strip == 'HostFibreChannelOverEthernetTargetTransport'))          
					Puppet.notice "Changing the multipath policy to #{resource[:policyname]} for FC or FCoE deviceID #{change_policy.id} is in progress."
					policySpec = RbVmomi::VIM::HostMultipathInfoFixedLogicalUnitPolicy(:policy => resource[:policyname], :prefer => "*")
					host.configManager.storageSystem.SetMultipathLunPolicy(:lunId => change_policy.id , :policy => policySpec)
					isPolicyApplied = true				
				end
			end
        end
	end
      if isPolicyApplied == false
        raise Puppet::Error, "Unable to find any FC or FCoE resources for multipath policy changes."
      end
    end
  rescue Exception => ex
    Puppet.err "Unable to change the policy to #{resource[:policyname]} because an unknown exception occurred. Verify the troubleshooting logs. If the issue persists, contact your service provider."
    Puppet.err ex.message
  end

  def exists?
    return false
  end

  def destroy
  end

  private

  def host
    @host ||= vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
  end

  #traverse dc
  def walk_dc(path=resource[:path])
    datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "No datacenter in path: #{path}") unless datacenter
    datacenter
  end
end

