# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	Get_ESX_IQNS

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

     Get_ESX_IQNS
     The Get_ESX_IQNS method displays the information about the  iSCSI adapter and the ISQN of the given host.

# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------

	host: (Required) This parameter defines the host ip/name.
	
	hostusername: (Required) This parameter defines the user name of the host sytem.
    
	hostpassword: (Required) This parameter defines the password of the host system.
	
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

esx_get_iqns { "get_iqns":
  host	       => '172.16.103.189',
  hostusername => 'root',
  hostpassword => 'iforgot@123', 
  transport    => Transport['vcenter'], 
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the esx_get_iqns.pp, and apply esx_get_iqns.pp for get_iqns operations, for example: 
   # puppet apply esx_get_iqns.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
