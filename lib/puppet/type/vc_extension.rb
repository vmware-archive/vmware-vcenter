# Copyright (C) 2014 VMware, Inc.
Puppet::Type.newtype(:vc_extension) do
  @doc = "Interface with vcenter extension manager"

  newparam(:name, :namevar => true) do
    desc "Extension name"
  end

  ensurable
end
