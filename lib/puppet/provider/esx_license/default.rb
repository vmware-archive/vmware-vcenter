# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_license).provide(:esx_license, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vSphere licenses in Virtual Center."

  def create
    vim.serviceContent.licenseManager.AddLicense(:licenseKey => resource[:license_key])
  end

  def destroy
    vim.serviceContent.licenseManager.RemoveLicense(:licenseKey => resource[:license_key])
  end

  def exists?
    vim.serviceContent.licenseManager.licenses.find{|lic| lic.licenseKey == resource[:license_key]}
  end
end
