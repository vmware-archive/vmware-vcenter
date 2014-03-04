# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

    - Create
        
	- Destroy

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

  1. Create
     The Create method adds a host to a datacenter or a cluster in a vCenter. However, it is a pre-requisite that the host must not already be present in the vCenter. 
   
  2. Destroy
     The Destroy method removes the host from datacenter or cluster in a vCenter. While removing the host from a cluster, the host must be in the maintenance mode. 

# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------
    
	ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: Present/Absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.

    name: (Required) This parameter defines the name or IP address of the host that needs to be added or removed from the datacenter/cluster in the vCenter. If this parameter is not provided explicitly in the manifest file, then the title of the type 'vc_host' is used.    
    
	username: (Required) This parameter defines the username as a part of the credentials of the host.            
    
	password: (Required) This parameter defines the password as a part of the credentials of the host.            

	path: (Required) This parameter defines the path where the host needs to be added. The path should be an absolute path. If it is a datacenter path, then the host is added to the datacenter. If it is a cluster path, then the host is added to the respective Cluster. 
            
    sslthumbprint: (Optional) This parameter defines the SSL thumbprint of the host.
            
	secure: (Optional) This parameter defines whether or not the vCenter server must require SSL thumbprint verification of host. 
    Possible values: True/False
    Default: False
            
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

#Provide any host property
vc_host { $esx1['hostname']:
  ensure           => present,
  username  => $esx1['username'],  
  password  => $esx1['password'],  
  path      => $datacenter1['path'],
  transport => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply vc_host.pp for various operations, for example: 
   # puppet apply vc_host.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------   
