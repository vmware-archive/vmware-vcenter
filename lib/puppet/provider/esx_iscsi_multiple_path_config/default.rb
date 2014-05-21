provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_iscsi_multiple_path_config).provide(:esx_iscsi_multiple_path_config, :parent => Puppet::Provider::Vcenter) do
  @doc = "ISCSI Storage multi-pathing configuration (Fixed / Round-Robin)"
  def create
    begin
      if host == nil
        raise Puppet::Error, "An invalid host name or IP address is entered. Enter the correct host name and IP address."
      else
        change_policy
      end
    rescue Exception => e
      fail "Unable to perform the operation because an unknown exception occurred. Verify the troubleshooting logs. If the issue persists, contact your service provider: -\n #{e.message}"
    end
  end

  def change_policy
    begin
      device_arr = host.configManager.storageSystem.storageDeviceInfo.multipathInfo.lun
      if device_arr == nil
        raise Puppet::Error, "Unable to find any native multipath storage resources on the specified host #{host}."
      else
        device_arr.each do |change_policy|
          paths = change_policy.path
          paths.each do |path|
            Puppet.notice "Changing the multipath policy to #{resource[:policyname]} for ISCSI deviceID #{change_policy.id} is in progress."
            policySpec = RbVmomi::VIM::HostMultipathInfoFixedLogicalUnitPolicy(:policy => resource[:policyname], :prefer => "*")
            host.configManager.storageSystem.SetMultipathLunPolicy(:lunId => change_policy.id, :policy => policySpec)
          end
        end
      end
    rescue Exception => e
      fail "Unable to change the policy to #{resource[:policyname]} because an unknown exception occurred. Verify the troubleshooting logs. If the issue persists, contact your service provider: -\n #{e.message}"
    end
  end

  def exists?
    return false
  end

end
