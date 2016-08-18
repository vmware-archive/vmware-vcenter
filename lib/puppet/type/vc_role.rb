# Copyright (C) 2016 VMware, Inc.
Puppet::Type.newtype(:vc_role) do
  @doc = "Manage vCenter Roles. http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.AuthorizationManager.Role.html"

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:name) do
    desc "The name of the role."
  end

  newparam(:force_delete) do
    desc "If false, prevents the role from being removed if any permissions are using it."
    defaultto(:false)
    newvalues(:true, :True, :false, :False)
  end

  newproperty(:privileges, :array_matching => :all) do
    desc "Array of privileges for the role."
    # Sort array to prevent unnecessary updates because resources aren't in the same order as returned by the API
    def insync?(is)
      Array(is).sort == Array(should).sort
    end
  end
end
