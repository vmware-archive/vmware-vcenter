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
    rescue Exception => exc
      Puppet.err "Unable to perform the operation because the following exception occurred - "
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
  
  #find hba
  def hba
#    @hba ||= host.configManager.storageSystem.storageDeviceInfo.hostBusAdapter.find{|a|
#      a.device == resource[:hba_name]}
        
    hba_arr = host.configManager.storageSystem.storageDeviceInfo.hostBusAdapter.grep(RbVmomi::VIM::HostFibreChannelOverEthernetHba)
        hba_arr.each do |hba|
          hba_nic = hba.underlyingNic
          if hba_nic == resource[:physical_nic]
            return hba
          end
        end
    return nil
  end
  
  #find host
  def host
    @host ||= vim.searchIndex.FindByDnsName(:dnsName => resource[:name], :vmSearch => false)
  end
  
end