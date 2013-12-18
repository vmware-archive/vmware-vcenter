# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_rescanallhba) do
  @doc = "Rescan all HBA"
  
  ensurable do
      newvalue(:present) do
          provider.create
      end
      newvalue(:absent) do
          provider.destroy
      end
      defaultto(:present)
    end
    
  newparam(:host, :namevar => true) do
    desc "ESX host:service name."
  end  
  end

 