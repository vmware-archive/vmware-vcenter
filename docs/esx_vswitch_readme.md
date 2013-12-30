# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------
	- create
	- destroy
	- nics
	- num_ports
	- nicorderpolicy
	- mtu
	- checkbeacon
	
# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

	1. create
		The Create method configures a vSwitch on the ESXi host and also attach pnics(if any) with the vSwitch.
   
	2. destroy
		The Destroy method destroys the vSwitch configured on ESXi host.
	 
	3. nics
		This method is used to configure physical network adapters on  a virtual switch. 
		
	4. nicorderpolicy
		This method is used to configure Failover order policy for network adapters on this vSwitch.
		
	5. mtu
		This method is used to configure the maximum transmission unit (MTU) of the virtual switch in bytes.
		
	6. checkbeacon
		This method is used to configure the flag to indicate whether or not to enable this property to enable beacon probing as a method to validate the link status of a physical network adapter.

# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

	ensure: (Optional) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    Default value: present
    If the value of the ensure parameter is set to present, then it calls the create method.
    If the value of the ensure parameter is set to absent, then it calls the destroy method.

	name: (Required) This parameter specifies the name of vSwitch to be created.
	host: (Required) This parameter defines the ESXi host ip/name.

	path: (Required) This parameter defines path to the esxi host.
	
	num_ports: (Optional) This parameter defines the number of ports that this virtual switch is configured to use. Changing this setting does not take effect until the next reboot. The maximum value is 1024, although other constraints, such as memory limits, may establish a lower effective limit. 
    Default: 128
    
    nics: (Optional) This parameter specifies array of the physical network adapters to be bridged. If an empty array is specified then any physical network adapters bridged to vSwitch will be deleted/unset.
	Default: Nics property will remain unchanged if in case nics property is not specified in manifest file.
	
	nicorderpolicy: (Optional) This parameter specifies the failover order policy for network adapters on this vSwitch. It is map of array which contains activenic and standbynic as key to respective arrays.
			activenic: This parameter is an array which specifies the order in which active nics are to be configured in accordance with failover order policy.
			standbynic: This parameter is an array which specifies the order in which standbynic nics are to be configured in accordance with failover order policy.
			
	Default: if this policy is not specified all nice will go to unused category.
	
	mtu: (Optional) This parameter specifies the maximum transmission unit (MTU) of the virtual switch in bytes.
	Default: 1500
	
	checkbeacon: (Optional) This parameter is the flag to indicate whether or not to enable this property to enable beacon probing as a method to validate the link status of a physical network adapter.
	Default: true
	
# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


#Configures vSwitch on ESXi host
esx_vswitch { 'name':
  ensure    => present,
  name      => "vSwitch1",
  host      => "esx1",
  path      => "/dc1/cl1/",
  num_ports => 120,
  nics      => ["pnic1", "pnic2", "pnic3", "pnic4"],
  nicorderpolicy => {
    activenic  => ["pnic1", "pnic2"],
    standbynic => ["pnic3", "pnic4"]
  },
  mtu            => 1500,
  checkbeacon    => true,
  transport => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply esx_vswitch.pp for various operations, for example: 
   # puppet apply esx_vswitch.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
