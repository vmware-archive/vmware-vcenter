# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_license_assignment).provide(:esx_license_assignment,
                  :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages assignment of vSphere licenses."

  def license_key
    if lam.nil?
      lm.licenses[0].licenseKey
    else
      lam.QueryAssignedLicenses(:entityId => entity)[0].assignedLicense.licenseKey
    end
  end

  def license_key=(value)
    if lam.nil?
      lm.UpdateLicense(:licenseKey => value)
    else
      lam.UpdateAssignedLicense(:entity => entity,
        :licenseKey => value)
    end
  end

  private

  # License Assignment Manager (virtual center only) shortcut
  #
  def lam
    @lam ||= lm.licenseAssignmentManager
  end

  def lm
    @lm ||= vim.serviceContent.licenseManager
  end

  # Locates a license entity
  #
  def entity
    @entity ||=
    begin
      detected = lam.QueryAssignedLicenses().find{|la| la.entityDisplayName == resource[:entity_id]}
      if detected
        detected.entityId
      else
        resource[:entity_id]
      end
    end
  end
end
