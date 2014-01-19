# VMware vCenter module

This module manages resources in VMware vCenter such as folders, datacenter,
ESX host and clusters.

## Description

VMware vCenter can be deployed either via an [virtual appliance (vmware-vcsa
module)](https://github.com/vmware/vmware-vcsa) or installed on a windows
server. This module manages vCenter 5.1 resources via the [vSphere
API](http://www.vmware.com/support/developer/vc-sdk/) using [rbvmomi
gem](https://github.com/vmware/rbvmomi):

    +------------+         +---------+         +-----+
    |            | vsphere | vCSA    |         | ESX |
    |   Puppet   | +-----> +---------+ +-----> +-----+
    | Management |   |                   |
    |    Host    |   |     +---------+   |     +-----+
    |            |    ---> | vCenter |    ---> | ESX |
    +------------+         +---------+         +-----+

* vCenter resources in this module are *NOT* compatible with PuppetLabs-vCenter module.
* ESX resources operate on hosts once they are attached to vCenter.

## Installation

$ puppet module install vmware/vcenter


## Access Mechanism 


The VMware/vCenter module uses the VMware vCenter Ruby SDK (rbvmomi, version 1.6.0) to interact with the VMware vCenter.


## Usage

Puppet management host (see diagram above) should install type/provider gem dependencies:

    include vcenter::package

Warning: nokogiri gem is an implicit requirement:
* Nokogiri package is shipped with Puppet Enterprise, but typically not
  installed by default on the agent. The platform appropriate PE nokogiri gem
should be installed on the management host (rather than building the gem).
* Open source puppet will automatically attempt to build nokogiri gem, but
  additional packages may be required for successful compilation (see
tests/package.pp example and [nokogiri installation
documentation](http://nokogiri.org/tutorials/installing_nokogiri.html)).

* This module ships with a custom version of rbvmomi gem for Ruby 1.8.7 compatibility.

Transport resource specifies rbvmomi connectivity info (see [VIM.connect
method](https://github.com/rlane/rbvmomi/blob/master/lib/rbvmomi/vim.rb) for
additional options):

    # The name of the transport is referenced by other resource:
    transport { 'lab':
      username => 'root',
      password => 'vmware',
      server   => 'vcsa.lab',
      options  => { 'insecure' => true },
    }

All vCenter resources use the transport metaparameter to specify the
connectivity used to manage the resource:

    vc_datacenter { 'dc1':
      path      => '/dc1',
      ensure    => present,
      transport => Transport['lab'],
    }
    
    vc_folder { '/dc1/folder1':
      ensure    => absent,
      transport => Transport['lab'],
    }

An ESX host can be attached and managed indirectly via vSphere API:

    vcenter::host { $esx1['hostname']:
      path      => '/dc1',
      username  => 'root',
      password  => 'password',
      dateTimeConfig => {
        'ntpConfig' => {
          'server' => 'us.pool.ntp.org',
        },
        'timeZone' => {
          'key' => 'UTC',
        },
      },
      transport => Transport['lab'],
    }

See tests folder for additional examples.
## References
### esx_fc_multiple_path_config


#### Supported Functionality

 
 Create

#### Functionality Description

 
  1. create
     This method checks whether specified host exists or not. If it is null, then it displays the error message: "host does not exists."
     If the host name exists, it will call the 'change_policy' method to apply the multi-path configuration change.
  
  2. change_policy
     This method performs the actual FC/FCoE multipath configuration changes.
     This method collects all the multipath LUN connected to the host bus adapter (HBA), and then looks for the LUN, which are connected through Fabric Channel (FC) with two or more number of available paths.
     After identifying the FC or FCoE LUNs, the multi-path configuration policy is applied to them one after the other.
     The path selection policy can be selected from one of below mentioned values:
     VMW_PSP_FIXED - Uses a preferred path whenever possible.
     VMW_PSP_RR - Uses Round Robin load balance.
     VMW_PSP_MRU - Uses the most recently used path.
   
#### Summary of Parameters

    ensure: (Required) This parameter is required to call the 'Create' method.
            The Possible values are: "present" and "absent"
            The Default value is : "present"
 
    host: (Required) This parameter defines the name or IP Address of the host machine.       
    policyname: (Required) This property defines the policy that needs to be applied.
    path: (Required) This parameter defines the path to the ESXi host.
 

#### Parameter Signature 

 
 transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_fc_multiple_path_config {$newVM['host']:
  ensure  => present,
  policyname  => 'VMW_PSP_RR',
  path  => '/Datacenter1',
  transport   => Transport['vcenter'],
}
 

#### Usage

   Refer to the examples in the test directory.
   
   You can provide inputs for 'host' in data.pp, and apply esx_fc_multiple_path_config.pp for various operations, for example:
   # puppet apply esx_fc_multiple_path_config.pp
   
   
   
### esx_fcoe



####  Supported Functionality
  Create
  Destroy


#### Functionality Description

  1. Create
     This method adds FCoE software adapter to a host. 
   
  2. Destroy
     This method deletes FCoE software adapter from a host.

#### Summary of Parameters
	ensure: (Required) This parameter is required to call the 'Create' or 'Destroy' method.
    The possible values are: "Present" and "Absent"
    If the ensure parameter is set to "Present", the module calls the 'Create' method.
    If the ensure parameter is set to "Absent", the module calls the 'Destroy' method.

	name: (Required) This parameter defines the name or IP address of the host to which a FCoE adapter needs to be added. It also defines the name of the underlying physical NIC that will be associated with the FCoE HBA. If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_fcoe' is used. 
    
    host: (Required) This parameter defines the name or IP address of the host.         

    physical_nic: (Required) This parameter defines the name of the underlying physical NIC that will be associated with the FCoE HBA. If this parameter is not defined explicitly in the manifest file, then the title of the type 'esx_fcoe' is used.

	path: (Required) This parameter defines the path to the ESXi host.
	
#### Parameter Signature 

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

#### Provide FCoE HBA property
esx_fcoe { "${esx1['hostname']}:vmnic0":
  ensure         => present,
  path           => "/Datacenter_path/",
  transport      => Transport['vcenter'],
}


#### Usage

   Refer to the examples in the test directory.
   
   You can provide the inputs in the data.pp, and apply esx_fcoe.pp for various operations, for example: 
   # puppet apply esx_fcoe.pp
   
### esx_datastore


####  Supported Functionality
    - Create
  
	- Destroy

#### Functionality Description
  1. Create
     The Create method adds a datastore to a host. 
   
  2. Destroy
     The Destroy method deletes a datastore from the host.


#### Summary of Parameters

    
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

	path: (Optional) This parameter defines the path to the ESXi host.

    Note: Provide the value of target_iqn in case of iSCSI, FC and FCoE storage. 
          Provide the value of lun in case of SCSI disk.
            

#### Parameter Signature 


transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

#### Provide datastore property
esx_datastore { "${esx1['hostname']}:vmfs_store":
  ensure    => present,
  lun	    => '0',  
  type      => 'vmfs',
  target_iqn => 'iqn.2006-01.com.openfiler:tsn.5f393ceedf4c',
  transport => Transport['vcenter'],
}

### esx_portgroup


####  Supported Functionality

        - Create
        - Destroy
        - Set VLAN Id
        - Set traffic shaping policy
        - Set IP configuration of the port group
		- Override the failover policy
		- Set mtu size
		- Set failback flag
		- Set checkbeacon flag

#### Functionality Description

  1. Create
     This method creates a port group instance based on the specified input parameters.
     As the port group gets created on a given vSwitch, the specific vSwitch must exist on the specified host.
     A user can set the port group type to either VirtualMachine or VMkernel (Used for vmotion and NIC teaming. Also, the IP address, the traffic shaping policy and the VLAN ID of the port group can be set by the user.
   
  2. Destroy
     This method removes the port group from the specified vSwitch.

  3. Set VLAN ID
     This method sets the VLAN Id of the created port group.
         
  4. Set traffic shaping policy
     This method sets the traffic shaping parameters in terms of average bandwidth, peak bandwidth and the burst size on the created port group.

  5. Set the IP configuration of the port group
     This method sets the IP settings (dhcp/static) on the created port group.
	 Note: To update the IP address, it is required to set the vMotion flag to "enabled", so that it gets enabled before updating the IP address to either dhcp/static.
	 
  6. override failover policy
	 This method overrides the failover order of vSwitch and sets it as per the input given by the user.
	 
  7. Set mtu size
	 This method sets the MTU size of the created port group.
	
  8. Set failback
	 This method sets the failback flag on the created  port group.
		
  9. Set checkbeacon
	 This method sets the checkbeacon flag on the created port group.
	 
####  Summary of Parameters.

  name: (Required) This parameter defines the name or IP address of the host to which portgroup needs to be added. It also defines the name of the portgroup to be created. If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_portgroup' is used. 
		example: 172.16.100.56:portgroup1

  ensure: (Required) This parameter is required to call the Create or Destroy method.
        Valid values: Present/Absent
        If the value of ensure parameter is set to present, the RA calls the Create method.
        If the value of ensure parameter is set to absent, the RA calls the Destroy method.
        Default value: Present

  portgrp: (Required) This parameter defines the port group to be created or already to be created.

  host: (Required) This parameter defines the Name/IPAddress of the host.

  path: (Required) This parameter defines the path to the host, for example: /Datacenter-1/cluster-1.
        
  vswitch:(Required) This parameter defines the name of the vSwitch.
        
  portgrouptype: (Required) This parameter defines the port group to be created by the user. 
        Valid values : "VirtualMachine" and "VMkernel"
        Default value: "VirtualMachine"

  vmotion: (Optional) This parameter notifies whether or not a vMotion is required on the VMkernel port group. This parameter is optional in case of the port group of the type "virtualMachine".
           Valid values : "enabled" and "disabled"
           
   overridefailback: (Optional) This parameter facilitates the user to override switch failback policy.
			Valid values : "enabled" and "disabled"
  overridecheckbeacon: (Optional) This parameter facilitates the user to override switch checkbeacon policy.
			Valid values : "enabled" and "disabled"			
			
  failback: This parameter is the value of failback policy.This is required if overridefailback is "enabled"
			Valid values : "true" and "false"
			
  checkbeacon : This parameter is the value of checkbeacon policy.This is required if overridecheckbeacon is "enabled" 
           Valid values : "true" and "false"
		   
  mtu :  (Optional) This paramter is used to specify the MTU size for this port group. A valid MTU value must not be less than 1500 and must not exceed 9000.
			
  overridefailoverorder : (Optional) This parameter facilitates the user to override switch failover order.
			Valid values : "enabled" and "disabled"
  
  nicorderpolicy : (Optional) This parameter gives option to the user to select active NICs and standby NICs for this port group. The value of this parameter must be in a hash format, for example: 
				nicorderpolicy => {
					activenic  => ["vmnic1"],
					standbynic => []
				},			
  ipsettings: (Optional) This parameter defines the IP settings required on the port group. 
            Valid values : "dhcp" and "static"
                         
  ipaddress: This parameter defines the IP address to be applied on the created port group. This parameter is required if the "ipsettings" parameter value is "static".
        
  subnetmask: This parameter is the subnetmask to be applied on the created port group. This parameter is required if the "ipsettings" parameter value is "static".

  traffic_shaping_policy: (Optional) This parameter defines the traffic shaping policy to be applied on the port group.
   Valid values : "enabled", "disabled"
                         
  averagebandwidth: (Optional) This parameter defines the average bandwidth to be applied on the port group. This parameter is used if the "traffic_shaping_policy" is enabled.
                   Default value: 1000 Kbits/sec
        
  peakbandwidth: (Optional) This parameter defines the peak bandwidth to be applied on the port group. This parameter is used if the "traffic_shaping_policy"" is enabled.
                 Default value: 1000 Kbits/sec
                        
  burtsize: (Optional) This parameter defines the burst size to be applied on the port group. This parameter is used if the traffic_shaping_policy"" is enabled.
            Default value: 1024 Kbytes
                        
  vlanid : (Optional) This parameter defines the VLAN Id to be set on the portgroup.
           Valid value: 0 to 4095
           Default value: 0 (No VLAN)

#### Parameter Signature 


transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

The following resource is not ready for testing:

  esx_portgroup { "172.16.100.56:portgroup1":
    name => "172.16.100.56:portgroup1",
    ensure => present,
    portgrouptype => "VMkernel",
    vmotion => "disabled",
	failback => "true",
	checkbeacon => "false",
	mtu => "2014",
	overridefailoverorder => "enabled",
	nicorderpolicy => {
    activenic  => ["vmnic1"],
    standbynic => []
	},
    ipsettings => "static",
    ipaddress => "172.16.12.16",
    subnetmask => "255.255.0.0",
    traffic_shaping_policy => "disabled",
    averagebandwidth => 1000,
    peakbandwidth => 1000,
    burstsize => 1024,
    vswitch => vSwitch1,
    path => "/Datacenter/cluster-1",
    vlanid => 5,
    transport => Transport['vcenter'],
  }


####  Usage
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply the esx_portgroup.pp for various operations, for example: 

   # puppet apply esx_portgroup.pp
   
### esx_rescanallhba

#### Supported Functionality

- Create
####  Functionality Description

 
  1. Create
  This method generates a request to rescan ESXi host bus adapters for new storage devices.
  This rescan of storage devices is needed when a storage device has been added, removed, or changed.
  The HBA re-scan and VMFS re-scan is to be performed in separate tasks. This is required because the rescan and VMFS 
  datastore detection are asynchronous processes, which can cause the detection process for new datastore to complete before 
  the detection of new LUNs is complete.
  The re-scanning must be followed by refreshing of the storage system to detect the changes occurred, if any.
   
#### Summary of Parameters.

   
    ensure: (Required) This parameter is required to call the Create method.
    Possible values: present/absent
    Default is : present
 
    host: (Required) This parameter defines the name/IP of the host machine.     
	
	path: (Required) This parameter defines the path to the ESXi host.    
 
 
#### Parameter signature 

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}
 
esx_rescanallhba {$newVM['host']:
  ensure  => present,
  host => $newVM['host'],
  path => '/Datacenter1',
  transport   => Transport['vcenter'],
}
 
#### Usage
   Refer to the examples in the test directory.
   
  A user can provide inputs for 'host' in data.pp, and apply esx_rescanallhba.pp for various operations, for example:
   # puppet apply esx_rescanallhba.pp

### esx_vswitch


####  Supported Functionality
	- create
	- destroy
	- nics
	- num_ports
	- nicorderpolicy
	- mtu
	- checkbeacon
	
#### Functionality Description

	1. create
		This method configures a vSwitch on the ESXi host and also attaches the nics(if any) with the vSwitch.
   
	2. destroy
		This method destroys the vSwitch configured on ESXi host.
	 
	3. nics
		This method is used to configure physical network adapters on a vSwitch 
		
	4. nicorderpolicy
		This method is used to configure Failover Order policy for network adapters on this vSwitch.
		
	5. mtu
		This method is used to configure the maximum transmission unit (MTU) of the virtual switch in bytes.
		
	6. checkbeacon
		This method is used to configure the flag to indicate whether or not to enable this property. If this property is enabled, it enables the beacon probing method to validate the link status of a physical network adapter.

#### Summary of Parameters

	ensure: (Optional) This parameter is required to call the 'Create' or 'Destroy' method.
            Possible values: "present" and "absent"
            Default value: present
            If the 'ensure' parameter is set to "present", then it calls the 'create' method.
            If the 'ensure' parameter is set to "absent", then it calls the 'destroy method.

	name: (Required) This parameter defines the name or IP address of the host to which vSwitch needs to be added. It also defines the name of the vSwitch to be created.If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_vswitch' is used. 
	
	vswitch: (Required) This parameter defines the name of vSwitch to be created.
	
	host: (Required) This parameter defines the ESXi host IP or host name.

	path: (Required) This parameter defines the path to the ESXi host.
	
	num_ports: (Optional) This parameter defines the number of ports that this vSwitch is configured to use. Changing this setting does not take effect until the next reboot. The maximum value is 4088, although other constraints, such as memory limits, may establish a lower effective limit. 
               Default value: 128
    
    nics: (Optional) This parameter defines the array of the physical network adapters to be bridged. If an empty array is defined, then any physical network adapters bridged to the vSwitch will be deleted or unset.
	      Default: Nics property will remain unchanged if nics property is not specified in manifest file.
	
	nicorderpolicy: (Optional) This parameter specifies the Failover Order policy for network adapters on this vSwitch. It is a map of array which contains activenic and standbynic as key to respective arrays.
			activenic: This parameter is an array which specifies the order in which active nics are to be configured based on the Failover Order policy.
			standbynic: This parameter is an array which specifies the order in which standbynic nics are to be configured based on the Failover Order policy.
			By default, if this policy is not defined, then all nice will be moved to unused category.
	
	mtu: (Optional) This parameter specifies the maximum transmission unit (MTU) of the vSwitch in bytes.
	     Default value: 1500
	
	checkbeacon: (Optional) This method is used to configure the flags to indicate whether or not to enable this property. If this property is  enabled, it enables the beacon probing method to validate the link status of a physical network adapter.
	              Default value: true
	
#### Parameter Signature 

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


Configures vSwitch on ESXi host
esx_vswitch { "esx1:vSwitch1":
  ensure    => present,
  name      => "esx1:vSwitch1",
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

#### Usage

   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply esx_vswitch.pp for various operations, for example: 
   # puppet apply esx_vswitch.pp

### vc_host	

#### Supported Functionality
    - Create
    - Destroy

#### Functionality Description

  1. Create
     The Create method adds a host to a datacenter or a cluster in a vCenter. However, it is a pre-requisite that the host must not already be present in the vCenter. 
   
  2. Destroy
     The Destroy method removes the host from datacenter or cluster in a vCenter. While removing the host from a cluster, the host must be in the maintenance mode. 

#### Summary of Parameters.

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
            
#### Parameter Signature 


transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Provide any host property
vc_host { $esx1['hostname']:
  ensure           => present,
  username  => $esx1['username'],  
  password  => $esx1['password'],  
  path      => $datacenter1['path'],
  transport => Transport['vcenter'],
}

#### Usage

   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply vc_host.pp for various operations, for example: 
   # puppet apply vc_host.pp

### vm_snapshot

The VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.
 
#### Supported Functionality

- snapshot_operation
- CreateSnapshot
- RevertToSnapshot
- RemoveSnapshot
 
#### Functionality Description
1.      A snapshot is a reproduction of the Virtual Machine, in a state that exists when the snapshot is taken using the snapshot feature. The snapshot includes the state of the data on all Virtual Machine disks, and the Virtual Machine power state (on, off, or suspended). A snapshot can be taken when a Virtual Machine is powered on, powered off, or suspended. When a snapshot is created, the system creates a delta disk file for that snapshot in the datastore, and writes any changes to that delta disk. You can later revert to the previous state of the Virtual Machine.
 
  CreateSnapshot : This method creates a new snapshot of the Virtual Machine. 
  RevertToSnapshot : This method reverts the virtual machine to the current snapshot. When a snapshot is reverted back, Virtual Machine is restored to the state it was in, when the snapshot was taken.
    RemoveSnapshot :- Deletes the snapshot of the virtual machine     
  
#### Summary of Parameters.

    name: This parameter defines the name of the Virtual Machine.
   
    ensure: This parameter is required to call the snapshot_operation.
    Possible values: present/absent
    
snapshot_operation: This parameter is required to execute the create, revert, or remove operations.
Possible values: create, revert, remove
 
    datacenter: This parameter defines the name of the datacenter.    
 
 memory_snapshot:Flag to create a memory dump of snapshot. If TRUE, a dump of the internal state of the virtual machine (basically a memory dump) is included in the snapshot 
 Possible values: true, false
 default value: true
 
 snapshot_supress_power_on : Flag to indicate whether the vm will be powered on before taking the snapshot
 Possible values: true, false
 default value: true
 
#### Parameter Signature 

 
transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}
 
 
vm_snapshot { $newVM['name']:
  name => $newVM['vm_name'],
 
  ensure => present,
  snapshot_operation => $newVM['operation'],
  datacenter => $newVM['datacenter'],
  transport => Transport['vcenter'],
}
 
#### Usage
   Refer to the examples, in the test directory.
   
   A user can provide inputs in data.pp, and apply vm_snapshot.pp for various operations, for example:
   # puppet apply vm_snapshot.pp
 
### vm_vnic

#### Supported Functionality

    - Create
    - Destroy
    - portgroup
 
#### Functionality Description
  1. Create
      The Create method adds a vNIC to the specified Virtual Machine. It is a pre-requisite for this operation
      that the Virtual Machine must be present in the vCenter. 

  2. Destroy
      The Destroy method deletes the vNIC from the Virtual Machine.

  3. portgroup
      The portgroup method attaches the portgroup to the vNIC.
 
#### Summary of Parameters.

  ensure: (Required) This parameter is required to call the Create or Destroy method.
           Possible values: present/absent
           Default value: present.
           If the value of the ensure parameter is set to present, the module calls the Create method.
           If the value of the ensure parameter is set to absent, the module calls the Destroy method.
 
  name:   (Optional, In case of ensure=present, Required, In case of ensure=absent)
           This parameter defines the name of the virtual NIC. The title of the type 'vm_vnic' is used,
           for example: Network Adaptor 1, Network Adaptor 2 etc.

  portgroup: (Required) This parameter defines the portgroup that is to be attached with the vNIC.

  vm_name: (Required) This parameter defines the name of the Virtual Machine.

  datacenter: (Required) This parameter defines the name of the datacenter.

  nic_type: (Optional) This parameter defines the NIC type of the vNIC.
             Possible values: "VMXNET 2", "E1000", or "VMXNET 3"
             Default value: E1000.

#### Parameter Signature 

 
    transport { 'vcenter':
       username => $vcenter['username'],
       password => $vcenter['password'],
       server   => $vcenter['server'],
       options  => $vcenter['options'],
    }
 
    vm_vnic { 'name'
       name => "Network Adaptor 1",
       ensure => present,
       vm_name => "testvm",
       nic_type => "E1000",
       datacenter => "DDCQA",
       transport => Transport['vcenter'],
    }

#### Usage
     Refer to the examples in the test directory.
    
   A user can provide the inputs in the data.pp, and apply vm_vnic.pp for various operations, for example: 
    puppet apply vm_vnic.pp
 
### esx_get_iqns

####  Supported Functionality

	Get_ESX_IQNS

#### Functionality Description
     Get_ESX_IQNS
     The Get_ESX_IQNS method displays the information about the  iSCSI adapter and the ISQN of the given host.

#### Summary of Parameters.
	host: (Required) This parameter defines the host ip/name.
	
	hostusername: (Required) This parameter defines the user name of the host sytem.
    
	hostpassword: (Required) This parameter defines the password of the host system.
	
#### Parameter Signature 


transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Provide any host property

esx_get_iqns { "get_iqns":
  host	       => '172.16.103.189',
  hostusername => 'root',
  hostpassword => 'iforgot@123', 
  transport    => Transport['vcenter'], 
}

#### Usage
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the esx_get_iqns.pp, and apply esx_get_iqns.pp for get_iqns operations, for example: 
   # puppet apply esx_get_iqns.pp
### esx_maintmode
####  Supported Functionality
	- Create
	- Destroy

#### Functionality Description

  1. Create
     The Create method switches the host to maintenance mode. While this task is running and when the host is in the maintenance mode, no virtual machines can be powered on and no provisioning operations can be performed on the host. After the call completion, it is safe to turn off the host without disrupting any virtual machines. 

   
  2. Destroy
     The Destroy method gets the host out of the maintenance mode. This action blocks if any concurrent running maintenance-only host configuration  operations are being performed, for example: if the VMFS volumes are being upgraded. 


#### Summary of parameters.

	ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.


    timeout: The task completes only when the host successfully enters the maintenance mode or the timeout expires, and in the latter case the task  contains a Timeout fault. If the timeout is less than or equal to zero, there is no timeout. The timeout is specified in seconds. 
    
    host: (Required) This parameter defines the host ip/name.
	
	evacuate_powered_off_vms: (Required) This is a parameter that is supported only by the VirtualCenter. If this parameter is set to true, the task does not succeed for a DRS disabled cluster, unless all powered-off virtual machines are manually re-registered. However, if this parameter is set to ture for a DRS enabled cluster, the VirtualCenter automatically re-registers the powered-off virtual machines, and a powered-off virtual machine might remain at the host only for the following two reasons: 

(a) No compatible host is found for re-registration.
(b) DRS is disabled for the virtual machine. 

If this parameter is set to false, the powered-off virtual machines are not required to be moved. 
	
#### Parameter signature 
transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Provide any host property
esx_maintmode { 'esx1':
  ensure => present,
  evacuate_powered_off_vms  => true,
  timeout   => $esx1['timeout'],  
  hostdns    => $esx1['host'],
  transport  => Transport['vcenter'],
}
#### Usage

   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply esx_maintmode.pp for various operations, for example: 
   # puppet apply esx_maintmode.pp

### esx_mem

####  Supported Functionality
	- configure_mem
	- install_mem
#### Functionality Description

  1. configure_mem
     The method configures MEM on the ESX server, and ensures the iSCSI end to end communication between the ESXi server and the iSCSI storage. 

  2. install_mem
     This method installs MEM software on the ESX server.
  
#### Summary of Parameters.

    configure_mem: (Required for the configure_mem operation) This parameter calls the configure_mem operation.
    Possible values: true

    install_mem: (Required for the install_mem operation) This parameter calls the install_mem operation.
    Possible values: true

    name: (Required)  The parameter defines the name of the ESX host.

    host_username: (Required) The parameter defines the username of the ESX host.
	
	host_password: (Required) The parameter defines the password of the ESX host.

    script_executable_path: (Required) This parameter defines the setup script executable path (/usr/bin/perl). 

    setup_script_filepath: (Required) This parameter defines the path of the MEM setup script. 

    vnics: (Required for the configure_mem operation) This parameter defines the ESX server physical NICs to use for iSCSI. This parameter can contain multiple values in a comma (,) separated format.

    vnics_ipaddress: (Required for configure_mem operation) This parameter defines the IP addresses to be used for iSCSI VMkernel ports. This parameter can contain multiple values in a comma (,) separated format.
    
    iscsi_vswitch: (Required for the configure_mem operation) This parameter defines the name of the iSCSI vSwitch.

    mtu: (Optional for configure_mem operation) This parameter defines the MTU for iSCSI vSwitch and VMkernel ports. 
    Default: 9000

    vmknics: (Required) This parameter defines the name of the VMkernel NIC. This parameter can contain multiple values with the space separated.
  
    iscsi_vmkernal_prefix: (Required for the configure_mem operation) This parameter defines the prefix to be used for VMkernel port names.

    iscsi_netmask: (Required for the configure_mem operation) This parameter defines the netmask to be used for iSCSI VMkernel ports.

    disable_hw_iscsi: (Required for the configure_mem operation) This parameter disables the Hardware iSCSI initiator.
    Possible values: true/false
    Default: false    
	
    storage_groupip: (Required for the configure_mem operation) This parameter defines the storage group IP address to be added as an iSCSI Discovery Portal.

    iscsi_chapuser: (Optional for the configure_mem operation) This parameter defines the CHAP username to be used for connecting to the volumes on the storage Group IP.
	
    iscsi_chapsecret: (Required if the iscsi_chapuser value is provided) This parameter defines the CHAP password to be used for connecting to the volumes on the storage Group IP.	
	

#### Parameter Signature 

import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


$mem = {
    'host'                      => '172.16.103.189',
    'script_executable_path'    => '/usr/bin/perl',
    'setup_script_filepath'     => '/root/scripts/setup.pl',
    'host_username'             => 'root',
    'host_password'             => 'iforgot@123',
}

$configure_mem = {
    'storage_groupip'           => '192.168.110.3',
    'iscsi_vmkernal_prefix'     => 'iSCSI',
    'iscsi_vswitch'             => 'vSwitch3',
    'vnics_ipaddress'           => '192.168.110.10,192.168.110.11',
    'iscsi_netmask'             => '255.255.255.0',
    'vnics'                     => 'vmnic2,vmnic3',
    'disable_hw_iscsi'          => 'true',
    'iscsi_chapuser'            => 'chap_user1',
    'iscsi_chapsecret'          => 'chap_pwd',
}


esx_mem { $mem['host']:
  configure_mem		        => "true",
  install_mem		        => "true",
  script_executable_path    => $mem['script_executable_path'],
  setup_script_filepath     => $mem['setup_script_filepath'],
  host_username             => $mem['host_username'],
  host_password             => $mem['host_password'],
  transport                 => Transport['vcenter'],
  storage_groupip           => $configure_mem['storage_groupip'],
  iscsi_vmkernal_prefix     => $configure_mem['iscsi_vmkernal_prefix'],
  vnics_ipaddress           => $configure_mem['vnics_ipaddress'],
  iscsi_vswitch             => $configure_mem['iscsi_vswitch'],
  iscsi_netmask             => $configure_mem['iscsi_netmask'],
  vnics                     => $configure_mem['vnics'],
  iscsi_chapuser            => $configure_mem['iscsi_chapuser'],
  iscsi_chapsecret          => $configure_mem['iscsi_chapsecret'],
  disable_hw_iscsi          => $configure_mem['disable_hw_iscsi'],
}

#### Usage
   Refer to the examples in the test directory.
   
  A user can provide the inputs in the iscsi_intiator_binding.pp, and apply the esx_mem.pp to install and configure mem on ESX server, for example: 
   # puppet apply esx_mem.pp

### iscsi_intiator_binding

####  Supported Functionality
	- Create
	- Destroy
#### Functionality Description

  1. Create
     This method binds the HBA to the VMkernel NICs.
   
  2. Destroy
     This method unbinds the HBA to the VMkernel NICs.
  
#### Summary of parameters.
    ensure: (Required) This parameter calls the Create or Destroy method.
    Possible values: Present/Absent
    If the value of ensure parameter is set to present, the Create method is called.
    If the value of ensure parameter is set to absent, the Destroy method is called.
	
	vmknics: (Required) This parameter defines the name of the VMkernel NIC. This parameter can contain multiple values with the space separated.
	
	script_executable_path: (Required) This parameter defines the path of the installed binary of the VMWare perl lib (/usr/bin/esxcli).

	host_name: (Required) The parameter defines the name of the ESX host.
	
	host_username: (Required) The parameter defines the username of the ESX host.
	
	host_password: (Required) The parameter defines the password of the ESX host.


#### Parameter Signature 

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


$esx_host = {
  'host_name'                 => '172.28.8.102',
  'script_executable_path'    => '/usr/bin/esxcli',
  'host_username'             => 'root',
  'host_password'             => 'P@ssw0rd',
}

$iscsi_details = {
  # Provide space separated VMkernel nics
  'vmknics'                     => 'vmk1',
}

iscsi_intiator_binding { "${esx_host['host_name']}:<vmhba>":
  ensure                    => present,
  vmknics                   => $iscsi_details['vmknics'],
  script_executable_path    => $esx_host['script_executable_path'],
  host_username             => $esx_host['host_username'],
  host_password             => $esx_host['host_password'],
  transport                 => Transport['vcenter'],
}

#### Usage
   Refer to the examples in the test directory.
   
  A user can provide the inputs in the iscsi_intiator_binding.pp, and apply the iscsi_intiator_binding.pp to bind or unbind the HBA to the VMKernel NIC, for example: 
   # puppet apply iscsi_intiator_binding.pp
### vc_migratevm
####  Supported Functionality
	- migratevm_host
	- migratevm_datastore
	- migratevm_host_datastore
#### Functionality Description

  1. migratevm_host: This method migrates a VMware Virtual Machine host to another host.
   
  2. migratevm_datastore: This method migrates a VMware Virtual Machine's storage to another datastore.


  3. migratevm_host_datastore: This method migrates a VMware Virtual Machine host to another host and moves its storage to another datastore.

#### Summary of Parameters
    datacenter: (Required) This parameter defines the name of the dataCenter.

    name: (Required) This parameter defines the name of the new Virtual Machine.
    
    migratevm_host: This parameter calls the 'migratevm_host' functionality to migrate the Virtual Machine host to another specified host.
    Syntax: migratevm_datastore =>  '<target host name>'
    Note: This parameter is required if a Virtual Machine host is to be migrated to another host.
    
    migratevm_datastore: This parameter calls the  'migratevm_datastore' functionality to migrate the Virtual Machine's storage to another specified datastore.
    Syntax: migratevm_datastore =>  '<target datastore name>'
    Note: This parameter is required if a Virtual Machine storage is to be migrated to another datastore.

    migratevm_host_datastore: This parameter calls the 'migratevm_host_datastore' functionality to migrate the VMware Virtual Machine host to another specified host and also migrates its storage to another specified datastore.
    Syntax: migratevm_host_datastore =>  '<target host name, target datastore name>'
    NOTE: This parameter is required if a Virtual Machine host and storage is to be migrated to another host and datastore, respectively.
          Target host and target datastore values must be comma (,) sperated values. The first value is considered as the host nameas the datastore value.
          
    
    diskformat: (Optional, used in case of 'migratevm_datastore' or 'migratevm_host_datastore' functionality) This parameter controls the type of disk created during the cloning operation.
    Possible values: thin/thick/same_as_source
    Default: same_as_source




#### Parameter Signature 

import 'data.pp'

$migrate_vm = {
    vmname => 'testVM',
    target_datastore => 'datastore3' ,
    target_host => '172.16.100.56' ,
    target => '172.16.100.56, gale-fsr',
    datacenter => 'DDCQA',
   
}

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


vc_migratevm { $migrate_vm['vmname']:
    migratevm_datastore => $migrate_vm['target_datastore'],
    #migratevm_host => $migrate_vm['target_host'],
    #migratevm_host_datastore => $migrate_vm['target'],
    datacenter => $migrate_vm['datacenter'],
    disk_format => 'thin' ,
    transport   => Transport['vcenter'],
}

#### Usage
  Refer to examples in the tests directory.
   
   A user can provide the inputs in the data.pp, and apply the vc_migratevm.pp for various operations, for example: 
   # puppet apply vc_migratevm.pp

### vc_vm_ovf


####  Supported Functionality
	- create
	- destroy

#### Functionality Description
  1. create: This method creates a new Virtual Machine by importing an OVF file.
  2. destroy: This method exports Virtual Machine OVF to a  specified location.

#### Summary of Parameters

    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.

    datacenter: (Required) This parameter defines the name of the dataCenter.

    name: (Required) This parameter defines the name of the new Virtual Machine.

    ovffilepath: (Required) This parameter defines the OVF file path.

    target_datastore: (Required) This parameter is used in case of create (import OVF). This parameter defines the name of the datastore where the new Virtual Machine is to be created.

    host: (Required) This parameter is used in case of the create (import OVF) method. This parameter defines the host name where the new Virtual Machine is to be created. 

    diskformat: (Optional) This parameter is used in case of the create (import OVF) method. This parameter controls the type of disk created during the import OVF operation.
    Possible values: thin/thick
    Default: thin



#### Parameter Signature 

import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


$ovf = {
    'vmname'                    => 'testVM',
    'ovffilepath'               => '/root/OVF/test.ovf',
    'datacenter'                => 'DDCQA',
    # For Import ovf
    'target_datastore'          => 'datastore3',
    'host'                      => '172.16.100.56' 
}


vc_vm_ovf { $ovf['vmname']:
  ensure                    => present,
  datacenter                => $ovf['datacenter'],
  ovffilepath               => $ovf['ovffilepath'],
  target_datastore          => $ovf['target_datastore'],
  host                      => $ovf['host'],
  transport                 => Transport['vcenter'],
}

#### Usage
  Refer to examples in the tests directory.
   
   A user can provide the inputs in the data.pp, and apply the vc_vm_ovf.pp for various operations, for example: 
   # puppet apply vc_vm_ovf.pp

### vc_vm


####  Supported Functionality
	- Create
	- Destroy
	- power_state

#### Functionality Description

  1. Create
     This method creates or clones a VMware Virtual Machine instance. Creation of virtual machine depends on the 'operation' 
     parameter value. If its value is set to 'create', the module will create a Virtual Machine from scratch. If its value
     is set to 'clone', Virtual Machine will be created based on the specified base image or on the base image template name.  
     
     The existing baseline Virtual Machine, must be available on a shared data-store and must be visible on all ESX hosts.
     The Virtual Machine capacity is allcoated based on the "numcpu" and "memorymb" parameter values, that are speicfied in the input file.
     NOTE: If multiple vNICs exist in the gold image, then the same number of vNICS get created in the new Virtual Machine.

   
  2. Destroy
     This method removes the Virtual Machine from the vCenter environment. The Virtual Machine is deleted from the disk.

  3. power_state
     This method allows the user to powerOn, powerOff, reset or suspend the Virtual Machine.

#### Summary of Parameters

    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of ensure parameter is set to present, the module calls the Create method.
    If the value of ensure parameter is set to absent, the module calls the Destroy method.    
        
    datacenter_name: (Required) This parameter defines the name of the datacenter.
    
    power_state: (Optional) This parameter can be used to powerOn, powerOff, reset or suspend the Virtual Machine.
    Possible values: poweredOff, poweredOn, suspended or reset.
    
    name: (Required) This parameter defines the name of the new Virtual Machine.
    
    operation: (Required) This parameter define the type of Virtual Machine creation.
    Possible values: create/clone
    If the value of operation parameter is set to create, the module will create Virtual Machine from scratch.
    If the value of operation parameter is set to clone, the module will create Virtual Machine based on the specified 
    base image or on the base image template name.
    
    #--------------------------------------------------------------------------
    # Create Virtual Machine parameter ( if operation is set to 'create' )
    #--------------------------------------------------------------------------
    
    host: (Required) This parameter defines the host name where the new Virtual Machine is to be created. 

    cluster: (Required) This parameter defines the cluster name where the new Virtual Machine is to be created. 
    NOTE:- If the cluster value is specified, the module ignores the specified host value in the input file.
           
    target_datastore: (Required) This parameter defines the name of the datastore containing the Virtual Machine. 
    
    diskformat: (Optional) This parameter controls the type of disk created.
    Possible values: thin/thick
    Default: thin
   
           
    memorymb: (Optional) This parameter defines the memory assigned to the new Virtual Machine. Its value must be provided in the MB.
    Default: 1024

    numcpu: (Optional) This parameter defines the number of CPU's assigned to the new Virtual Machine.
    Default: 1
    
    disksize: (Optional) This parameter defines the capacity of the virtual disk (in KB).
    Default: 4096
    
    memory_hot_add_enabled: (Optional) This parameter indicates whether or not memory can be added to the virtual machine while it is running.
    Possible values: true/false
    Default: true 
    
    cpu_hot_add_enabled: (Optional) This parameter indicates whether or not virtual processors can be removed from the virtual machine while it is running
    Possible values: true/false
    Default: true  
    
    guestid: (Optional) This parameter defines the guest operating system identifier. User can get the guestif from following url
    https://www.vmware.com/support/developer/vc-sdk/visdk25pubs/ReferenceGuide/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    
    portgroup: (Optional) This parameter defines the portgroup that is to be attached with the Virtual Machine vNIC.
    Default: "VM Network"  
    
    nic_count: (Optional) This parameter defines the number of vNics that is to be created on the Virtual Machine.
    Default: 1  
    
    nic_type: (Optional) This parameter defines the NIC type of the vNIC.
    Possible values: VMXNET 2/E1000/VMXNET 3
    Default value: E1000
    
    
    #--------------------------------------------------------------------------
    # Create Virtual Machine parameter ( if operation is set to 'clone' )
    #--------------------------------------------------------------------------
    
    host: (Optional) This parameter defines the host name where the new Virtual Machine is to be created. 

    cluster: (Optional) This parameter defines the cluster name where the new Virtual Machine is to be created. 
    NOTE:- If the cluster value is specified, the module ignores the specified host value in the input file.
           If both the parameter values are not provided, the module attempts to create a new Virtual Machine in the gold Virtual Machine host.
           
    target_datastore: (Optional) This parameter defines the name of the datastore containing the Virtual Machine. If not provided, the Virtual Machine is created on the available datastore.
    
    diskformat: (Required) This parameter controls the type of disk created.
    Possible values: thin/thick
    Default: thin
   
           
    memorymb: (Optional) This parameter defines the memory assigned to the new Virtual Machine. Its value must be provided in the MB.
    Default: 1024

    numcpu: (Optional) This parameter defines the number of CPU's assigned to the new Virtual Machine.
    Default: 1    
    

    goldvm: This parameter defines the name of the gold Virtual Machine.

    goldvm_datacenter: (Optional) This parameter defines the name of the gold Virtual Machine's dataCenter. This parameter is required if the gold Virtual Machine belongs to a different datacenter or if the user wants to clone a new Virtual Machine across dataCenter.
    Note: In this case the user is supposed to provide the following parameter values.
    Either cluster or host, and target_datastore. 
    

    diskformat: (Optional) This parameter controls the type of disk created during the cloning operation.
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

	

#### Parameter Signature 
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


vc_vm { $newVM['vmName']:
    ensure                         => $newVM['ensure'],
    transport                      => Transport['vcenter'],
    operation                      => $newVM['operation'],
    datacenter_name                => $newVM['datacenter'],
    memorymb                       => $newVM['memoryMB'],
    numcpu                         => $newVM['numCPU'],
    host                           => $newVM['host'],
    cluster                        => $newVM['cluster'],
    target_datastore               => $newVM['target_datastore'],
    diskformat                     => $newVM['diskformat'],
    
    # Create VM Parameters
    # disk size should be in KB
    disksize                       => $createVM['disksize'],
    memory_hot_add_enabled         => $createVM['memory_hot_add_enabled'],
    cpu_hot_add_enabled            => $createVM['cpu_hot_add_enabled'],
    # user can get the guestif from following url
    # https://www.vmware.com/support/developer/vc-sdk/visdk25pubs/ReferenceGuide/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    guestid                        => $createVM['guestid'],
    portgroup                      => $createVM['portgroup'],
    nic_count                      => $createVM['nic_count'],
    nic_type                       => $createVM['nic_type'],

    # Clone VM parameters
    goldvm                         => $goldVMName['name'],
    dnsdomain                      => $cloneVM['dnsDomain'],

    #Guest OS nic specific params
    nicspec => {
        nic => [{
            ip        => $cloneVM['ip1'],
            subnet    => $cloneVM['subnet1'],
            dnsserver => $cloneVM['dnsserver1'],
            gateway   => $cloneVM['gateway1']
        },{
            ip        => $cloneVM['ip2'],
            subnet    => $cloneVM['subnet1'],
            dnsserver => $cloneVM['dnsserver1'],
            gateway   => $cloneVM['gateway1']
        }],
    },

    #Guest Customization Params
    guestcustomization              => $cloneVM['guestCustomization'],
    guesthostname                   => $cloneVM['guesthostname'],
    guesttype                       => $cloneVM['guesttype'],
    #Linux guest os specific
    linuxtimezone                   => $cloneVM['linuxtimezone'],
    #Windows guest os specific
    windowstimezone                 => $cloneVM['windowstimezone'],
    guestwindowsdomain              => $cloneVM['guestwindowsdomain'],
    guestwindowsdomainadministrator => $cloneVM['guestwindowsdomainadministrator'],
    guestwindowsdomainadminpassword => $cloneVM['guestwindowsdomainadminpassword'],
    windowsadminpassword            => $cloneVM['windowsadminpassword'],
    productid                       => $cloneVM['productid'],
    windowsguestowner               => $cloneVM['windowsguestowner'],
    windowsguestorgnization         => $cloneVM['windowsguestorgnization'],
    customizationlicensedatamode    => $cloneVM['customizationlicensedatamode'],
    autologon                       => $cloneVM['autologon'],
    autologoncount                  => $cloneVM['autologoncount'],
    autousers                       => $cloneVM['autousers'],
    
}


#### Usage

   Refer to examples in the tests directory.
   
   A User can provide inputs in data.pp, and apply vc_vm.pp for various operations, for example: 

   # puppet apply vc_vm.pp

### vc_vm_register	
#### Supported Functionality

	- Create
	- Destroy
####  Functionality Description

  1. Create
     This method registers the virtual machine with the inventory.

  2. Destroy
     This method removes the Virtual Machine from the inventory.

  
#### Summary of Parameters.


   
    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: Present/Absent
    If the value of ensure parameter is set to present, the Create method is called.
    If the value of ensure parameter is set to absent, the Destroy method is called.
	
	name: (Required) This parameter indicates the name by which the Virtual Machine is to be registered, while registering the Virtual Machine. However, while removing the Virtual Machine from the inventory, the "name" parameter indicates the name of the Virtual Machine that is to be removed.
	
	datacenter:(Required) This parameter defines the name of Data Center.
	
	#To register a Virtual Machine 
		
	hostip:(Required) This parameter defines the IP address of the target host on which the Virtual Machine will run.
	astemplate:(Required) This parameter specifies a flag to specify whether or not the Virtual Machine must be marked as a template.
	vmpath_ondatastore:(Required) This parameter describes a  datastore path to the Virtual Machine.  
	
    


#### Parameter Signature 


transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vm_register { $newVM['name']:
  ensure     => $newVM['ensure'],
  transport  => Transport['vcenter'],
  #to register vm
  datacenter => $newVM['datacenter'],  
  hostip       => $newVM['hostip'],
  astemplate => $newVM['astemplate'],
  vmpath_ondatastore  => $newVM['vmpath_ondatastore'], 
  
 }

#### Usage
   Refer to the examples in the test directory.
   
  A user can provide inputs in data_regsitervm.pp, and apply the vc_vm_register.pp to register or remove the Virtual Machine to/from inventory, for example: 
   # puppet apply vc_vm_register.pp





