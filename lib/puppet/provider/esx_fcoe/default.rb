provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'

Puppet::Type.type(:esx_fcoe).provide(:esx_fcoe, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage FCoE software adapters in vCenter hosts."
  
  # Add FCoE software adapter.
  def create
    begin
      # create spec
      spec = RbVmomi::VIM.FcoeConfigFcoeSpecification(:underlyingPnic => resource[:physical_nic])
              
      # discover fcoe HBA
      host.configManager.storageSystem.DiscoverFcoeHbas(:fcoeSpec => spec)
      Puppet.notice("FCoE software adapter has been added to the host.")
    rescue Exception => exc
      Puppet.err "Unable to perform the operation because the following exception occurred. Make sure to provide correct physical nic that will be associated with the FCoE HBA."
      Puppet.err(exc.message)
    end
  end

  # Remove FCoE software adapter.
  def destroy
    begin
      #retrieve existing HBA
      fcoe_hba = hba
      
      #remove fcoe HBA
      host.configManager.storageSystem.MarkForRemoval(:hbaName => fcoe_hba.device, :remove => true)
      Puppet.notice("FCoE software adapter has been removed from the host. The host needs to be rebooted for changes to take effect.")
    rescue Exception => exc
      Puppet.err "Unable to perform the operation because the following exception occurred - "
      Puppet.err(exc.message)
    end
  end

  # Check to see if FCoE software adapter exist.
  def exists?
    hba
  end

  private 
  
  #find hba given the physical nic
  def hba
    hba_arr = host.configManager.storageSystem.storageDeviceInfo.hostBusAdapter.grep(RbVmomi::VIM::HostFibreChannelOverEthernetHba)
        hba_arr.each do |hba|
          hba_nic = hba.underlyingNic
          if hba_nic == resource[:physical_nic]
            return hba
          end
        end
    return nil
  end
  
  #find host given the host IP or name
  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:host], :vmSearch => false)
    if @host
      return @host
    else
      fail "Make sure to provide correct name or IP address of the host."
    end
  end
  
end