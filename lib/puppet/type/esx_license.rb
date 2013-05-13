# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_license) do
  @doc = "Adds licenses to Vcenter pool.  Does not assign them to managed "\
          "entities (esxi, vcenter).  Use esx_license_assignment to assign "\
          "licenses to entities."

  newparam(:license_key, :namevar => true) do
    desc "License key"
  end

  ensurable
end
