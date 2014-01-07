 
 # --------------------------------------------------------------------------
 # Access Mechanism 
 # --------------------------------------------------------------------------
 
  The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.
 
 # --------------------------------------------------------------------------
 #  Supported Functionality
 # --------------------------------------------------------------------------
 
    - Create
    - Destroy
    - portgroup
 
 # -------------------------------------------------------------------------
 # Functionality Description
 # -------------------------------------------------------------------------
 
  1. Create
      The Create method adds a vNIC to the specified Virtual Machine. It is a pre-requisite for this operation
      that the Virtual Machine must be present in the vCenter. 

  2. Destroy
      The Destroy method deletes the vNIC from the Virtual Machine.

  3. portgroup
      The portgroup method attaches the portgroup to the vNIC.
 
 # -------------------------------------------------------------------------
 # Summary of Parameters.
 # -------------------------------------------------------------------------

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

 # -------------------------------------------------------------------------
 # Parameter Signature 
 # -------------------------------------------------------------------------
 
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

 # --------------------------------------------------------------------------
 # Usage
 # --------------------------------------------------------------------------
    Refer to the examples in the test directory.
    
   A user can provide the inputs in the data.pp, and apply vm_vnic.pp for various operations, for example: 
   # puppet apply vm_vnic.pp
 
 #-------------------------------------------------------------------------------------------------------------------------
 # End
 #------------------------------------------------------------------------------------------------------------------------- 