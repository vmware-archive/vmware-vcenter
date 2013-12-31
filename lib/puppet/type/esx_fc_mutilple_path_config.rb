# Copyright (C) 2013 VMware, Inc.
Puppet::Type.newtype(:esx_fc_mutilple_path_config) do
  @doc = "FC / FCoE Storage multi-pathing configuration (Fixed / Round-Robin)"
  
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
    desc "ESX host:service IP/name."
    validate do |value|
        if value.strip.length == 0
          raise ArgumentError, "Invalid name or IP address of the host."
        end
      end	
  end  
  
  newproperty(:policyname) do
    desc "String representing the path selection policy for a device. Use one of the following strings:
        VMW_PSP_FIXED - Use a preferred path whenever possible.
        VMW_PSP_RR - Round Robin Load balance.
        VMW_PSP_MRU - Use the most recently used path."
    newvalues(:VMW_PSP_RR, :VMW_PSP_FIXED, :VMW_PSP_MRU)
  end   
  end