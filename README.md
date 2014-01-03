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
Following functionality related readme's are kept at docs folder.

1) vc_vm_readme.md: This readme file talks about following VMware functionalities.
   a) Creating the VMware Virtual Machine instance based on the specified base image or the base image template name. 
   b) Deleting the Virtual Machine from the vCenter environment.
   
2) esx_maintmode.md: This readme file talks about following host system functionalities.
   a) Switches the host in to maintenance mode.
   b) Gets the host out of the maintenance mode.
    
3) vc_host_readme.md: This readme file describes following host system functionalities.
   a) Adding host to a Datacenter or a Cluster.
   b) Removing host from a Datacenter or a Cluster.
   
4) esx_rescanallhba_readme.md: This readme file talks about following host system functionalities.
   a) Re-scan ESXi HBAs for new storage devices. 
   
5) vm_snapshot_readme.md: This readme file talks about following VMWare functionalities.
   a) Creates a new snapshot of the Virtual Machine. 
   b) Reverts the virtual machine to the current snapshot.
   c) Deletes the snapshot of the virtual machine.

6) vc_migratevm_readme.md: This readme file talks about following migrate vm functionalities.
   a) Migrating a VMware Virtual Machine host to another host.
   b) Migrating a VMware Virtual Machine's storage to another datastore.
   c) Migrating a VMware Virtual Machine host to another host and moves its storage to another datastore.
   
7) vc_vm_register_readme.md: This readme file describes following fucntionality.
   a) Registering virtual machine to inventory.
   b) Removing virtual machine from inventory.

8) esx_datastore_readme.md: This readme file describes following host system functionalities.
   a) Adding datastore to a host.
   b) Deleting datastore from a host.

9) vc_vm_ovf_readme.md: This readme file describes following functionalities.
   a) Creating a new Virtual Machine by importing a OVF file.
   b) Exporting a Virtual Machine OVF to the specified location.

10) esx_fcoe_readme.md: This readme file describes following host system functionalities.
   a) Adding FCoE software adapter to a host.
   b) Deleting FCoE software adapter from a host.
   
11) esx_get_iqns_readme.md:This readme file describes following host system functionalty.
   a)Displaying the information about the iSCSI adapter and the ISQN of the given host.

12) esx_mem_readme.md:This readme file describes following host system functionalty.
   a)Installing and configuring MEM on ESX server.
   
13) iscsi_intiator_binding_readme.md:This readme file describes following host system functionalty.
   a)Binding and Unbinding of VMKernel nic to VM HBA.