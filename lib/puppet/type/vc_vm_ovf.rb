Puppet::Type.newtype(:vc_vm_ovf) do
  @doc = "Export and Import OVF."

  ensurable do
    newvalue(:import) do
        provider.create
    end
    newvalue(:export) do
        provider.destroy
    end
    defaultto(:import)
  end

  newparam(:ovffilepath) do
       desc "OVF file path."
  end
 
  newparam(:name, :namevar => true) do
    desc "The virtual machine name."
  end

  newparam(:datacenter) do 
    desc "Name of the datacenter."
  end
  
   newparam(:target_datastore) do
       desc "name of destination datastore."
  end
   newparam(:host) do
       desc "name of Host."
  end
  
  newparam(:disk_format) do
       desc "Name of the datastore disk type."
    newvalues(:thin, :thick)
    defaultto(:thin)
    munge do |value|
        value.to_s
    end
  end
  
end
