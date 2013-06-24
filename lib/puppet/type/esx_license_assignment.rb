# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_license_assignment) do
  @doc = "Manage vsphere license assignment.  "\
          "entity_id should be the name of an esx host or vcenter.  Licenses "\
          "can only be assigned to one entity at a time."

  newparam(:entity_id, :namevar => true) do
  	desc "Name of ESX or Virtual Center node associated with the license key"
  end

  newproperty(:license_key) do
  	desc "vSphere License Key"
  end

end
