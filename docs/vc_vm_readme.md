
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Create
	- Destroy
	- power_state

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Create
     This method creates a VMware Virtual Machine instance based on the specified base image or the base image template name. 
     The existing baseline Virtual Machine, must be available on a shared data-store and must be visible on all ESX hosts.
     The Virtual Machine capacity is allcoated based on the "numcpu" and "memorymb" parameter values, that are speicfied in the input file.
     NOTE: If multiple vNICs exist in the gold image, then the same number of vNICS get created in the new Virtual Machine.

   
  2. Destroy
     This method removes the Virtual Machine from the vCenter environment. The Virtual Machine is deleted from the disk.

  3. power_state
     This method allows the user to powerOn, powerOff, reset or suspend the Virtual Machine.

# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------

   
    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of ensure parameter is set to present, the module calls the Create method.
    If the value of ensure parameter is set to absent, the module calls the Destroy method.

    datacenter_name: (Required) This parameter defines the name of the datacenter.

    power_state: (Optional) This parameter can be used to powerOn, powerOff, reset or suspend the Virtual Machine.
    Possible values: poweredOff, poweredOn, suspended or reset.

    goldvm:  This parameter defines the name of the gold Virtual Machine.

    goldvm_datacenter: (Optional) This parameter defines the name of the gold Virtual Machine's dataCenter. This parameter is required if the gold Virtual Machine belongs to a different datacenter or if the user wants to clone a new Virtual Machine across dataCenter.
    Note: In this case the user is supposed to provide the following parameter values.
    Either cluster or host, and target_datastore.

    
    name: (Required) This parameter defines the name of the new Virtual Machine.
    
    memorymb: This parameter defines the memory assigned to the new Virtual Machine. Its value must be provided in the MB.
    Default: 1024

    numcpu: This parameter defines the number of CPU's assigned to the new Virtual Machine.
    Default: 1

    host: (Optional) This parameter defines the host name where the new Virtual Machine is to be created. 

    cluster: (Optional) This parameter defines the cluster name where the new Virtual Machine is to be created. 
    NOTE:- If the cluster value is specified, the module ignores the specified host value in the input file.
           If both the parameter values are not provided, the module attempts to create a new Virtual Machine in the gold Virtual Machine host.
 
    target_datastore: (Optional) This parameter defines the name of the datastore containing the Virtual Machine. If not provided, the Virtual Machine is created on the available datastore.

    diskformat: (Required) This parameter controls the type of disk created during the cloning operation.
    Possible values: thin/thick
    Default: thin

   GuestCustomization parameters

    guestcustomization: (Required) This parameter is required if the guest customization is needed on the Virtual Machine.
    Possible values: true/false
    Default: false
    
    guesthostname: (Optional). This parameter is used if the guestcustomization is true. This parameter defines the host name of the Virtual Machine. If the value is not enttered, the host name remains the same as the vmname.

    guesttype: (Required) This parameter is used if the guestcustomization is true. This parameter indicates the type of guest operating system.
    Possible values: windows/linux
    Default: windows

    nicspec: This parameter holdsthe following virtual NICs specification parameter values. NIC specification parameters are as follows:

        ip: (Optional) This parameter sets the static IP address to the Virtual Machine. If left blank, the module uses the DHCP to set the IP address. (Optional)

        subnet: (Required if the IP address is specified). This parameter sets the Default Gateway on the NIC.

        dnsserver: (Required if the IP address is specified).
        This sets the default subnet mask on the NICs.

        gateway: (Required if IP address is specified). 
        This parameter sets the DNS servers on the NICs.
        If multiple DNS servers exist, then the values are separated using a colon ":". (Optional).



    #--------------------------------------------------------------------------
    # Guest Customization Specific Properties(For Linux)
    #--------------------------------------------------------------------------

    linuxtimezone: (Required) This parameter sets the timezone property for a linux guest operating system.
    
    dnsdomain: A fully qualified domain name is required for Linux Virtual machine.

    #--------------------------------------------------------------------------
    # Guest Customization Specific Properties(For Windows)
    #--------------------------------------------------------------------------

    dnsdomain: This parameter sets the default domain for the guest network.
    
    windowstimezone: (Optional) This parameter sets the timezone property for a windows guest operating system.

    guestwindowsdomain: (Optional) This parameter defines the domain that a virtual machine must join. If this value is provided, then the GuestWindowsDomainAdministrator and GuestWindowsDomainAdminPassword must also be provided.

    guestwindowsdomainadministrator: (Required, if guestwindowsdomain is specified.) This is the domain user account used for authentication if the  Virtual Machine joins a domain.
    The user is not required to be a domain administrator, but the account must have the privileges 
    required to add computers to the domain.

    guestwindowsdomainadminpassword: (Required, if guestwindowsdomain is specified.) This is the password for the domain user account used for authentication if the Virtual Machine joins a domain.

    windowsadminpassword: (Optional, used if guesttype='windows') The administrator password for the Windows Virtual Machine.

    windowsguestowner: (Optional, used if guesttype='windows') This is the Windows guest owner name. If a parameter is not specified, the 'TestOwner' value is set as guest Windows owner. 

    windowsguestorgnization: (Optional, used if guesttype='windows') This is the Windows guest organization name. If a parameter is not specified, the 'TestOrg' value is set as guest Windows organization. 

    productid: (Optional, used if GuestCustomizationRequired='True') This parameter holds the license key used for the guest OS. Either specify the correct ProductId or keep it empty. There could be instances where the setting does not gets applied on the OS in case of wrong ProductId.

    customizationlicensedatamode: This paramter indicates the client access license mode for accessing VirtualCenter server.  
    Possible values: perSeat/perServer
    Default: perServer

    autousers: (Optional, used if customizationlicensedatamode='perServer') The parameter value indicates the number of client licenses purchased for the VirtualCenter server being installed. 
    Default: 1

    autologon: This parameter value determines whether or not the machine automatically logs in as Administrator.
    Possible values: true/false
    Default: true

    autologoncount: (Optional, used if autologon='true') This parameter value specifies the number of times the machine must  automatically log on as Administrator. 
    Default: 1    

    


# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


vc_vm { $newVM['vmName']:
  ensure     => present,
  datacenter => $newVM['datacenter'],
  goldvm => $goldVMName['name'],
  memorymb => $newVM['memoryMB'],
  dnsdomain => $newVM['dnsDomain'],
  computername => $newVM['computerName'],
  numcpu => $newVM['numCPU'],
  transport  => Transport['vcenter'],
  host => $newVM['host'],
  cluster => $newVM['cluster'],
  guestcustomization => 'false',
  
  nicspec => {
    nic => [{
      ip    => $newVM['ip1'],
      subnet => $newVM['subnet1'],
	  dnsserver => $newVM['dnsserver1'],
	  gateway => $newVM['gateway1']
    }],
    nic => [{
      ip    => $newVM['ip2'],
      subnet => $newVM['subnet2'],
	  dnsserver => $newVM['dnsserver2'],
	  gateway => $newVM['gateway2']
    }],
  } 

}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to examples in the tests directory.
   
   A User can provide inputs in data.pp, and apply vc_vm.pp for various operations, for example: 

   # puppet apply vc_vm.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
