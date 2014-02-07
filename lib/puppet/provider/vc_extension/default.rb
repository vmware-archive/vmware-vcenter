# Copyright (C) 2014 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_extension).provide(:vc_extension, :parent => Puppet::Provider::Vcenter) do
  @doc = "Interface to vcenter extension manager"

  def create
    Puppet.debug("Create is not yet implemented for vcenter extension manager")
  end

  def destroy
    vim.serviceContent.extensionManager.UnregisterExtension(:extensionKey => resource[:name])
  end

  def exists?
    vim.serviceContent.extensionManager.extensionList.find{|ext| ext.key == resource[:name]}
  end
end
