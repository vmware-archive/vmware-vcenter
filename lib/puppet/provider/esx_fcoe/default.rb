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
      Puppet.notice("Successfully added the FCoE software adapter to the host.")
    rescue Exception => exc
      Puppet.err "Unable to add FCoE software adapter because an unknown exception occurred.  Make sure the specified physical network interface card (NIC), which needs to be associated with the FCoE, is valid, and then try again the operation. If the issue persists, verify the troubleshooting logs or contact your service provider."
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
      Puppet.notice("Successfully removed the FCoE software adapter from the host. Reboot the host for the changes to take effect.")
    rescue Exception => exc
      Puppet.err "Unable to remove FCoE software adapter because the following exception occurred - "
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
    @host ||= vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
    if @host
      return @host
    else
      fail "An invalid host name or IP address is entered. Enter the correct host name and IP address."
    end
  end

  #traverse datacenter
  def walk_dc(path=resource[:path])
    datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "No datacenter in path: #{path}") unless datacenter
    datacenter
  end

end