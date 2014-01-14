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
     The Create method adds a datastore to a host. 
   
  2. Destroy
     The Destroy method deletes a datastore from the host.

# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------
    
	ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: Present/Absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.

    name: (Required) This parameter defines the name or IP address of the host to which a datastore needs to be added. It also defines the name of the datastore. If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_datastore' is used.        
    
	host: (Required) This parameter defines name or IP address of the host to which a datastore is to be added. If this parameter is not provided explicitly in the manifest file, then either the title of the type 'esx_datastore' is used or the 'name' parameter is used.       
    
    datastore: (Required) This parameter defines the name of the datastore. If this parameter is not provided explicitly in the manifest file, then either the title of the type 'esx_datastore' is used or the 'name' parameter is used.

	type: (Required) This parameter defines the datastore type.
    Possible values: NFS / CIFS / VMFS
	
	lun:  This parameter defines the LUN number of storage volume.
	
	target_iqn: (Storage IQN) This parameter defines a worldwide unique and valid name for the iSCSI target instances. The name, based on IETF RFC 3270, can be between 1 and 244 characters in length. Sample formats are: 'iqn.2006-01.com.openfiler:tsn.5f393ceedf4c' can be get from esx_get_iqns api. 

	path: (Required) This parameter defines the path to the ESXi host.

            
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

#Provide datastore property
esx_datastore { "${esx1['hostname']}:vmfs_store":
  ensure    	=> present,
  lun	    	=> '0',  
  type      	=> 'vmfs',
  target_iqn 	=> 'iqn.2006-01.com.openfiler:tsn.5f393ceedf4c',
  transport 	=> Transport['vcenter'],
}

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------   
