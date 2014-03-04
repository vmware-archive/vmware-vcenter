# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_rescanallhba).provide(:esx_rescanallhba, :parent => Puppet::Provider::Vcenter) do
  @doc = "Rescan all HBA"
  def create
    begin
      if host == nil
        raise Puppet::Error, "An invalid host name or IP address is entered. Enter the correct host name and IP address."
      else
        Puppet.notice "Re-Scanning for all HBAs."
        host.configManager.storageSystem.RescanAllHba()
        Puppet.notice "Re-Scanning for VMFS."
        host.configManager.storageSystem.RescanVmfs()
        Puppet.notice "Re-freshing Storage System."
        host.configManager.storageSystem.RefreshStorageSystem()
      end
    end
  rescue Exception => ex
    Puppet.err "Unable to perform the operation because the following exception occurred."
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

