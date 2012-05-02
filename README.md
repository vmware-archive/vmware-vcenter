# vcenter puppet module

VMware vCenter management

## Install

Paramaters:

* media: installation softare media location.
* username: vcenter service account (default: VCENTER).
* password: vcenter service account password (default: 'vCenter2008demo').
* jvm_memory_option: vcenter sql server size, support S, M, L.
* client: install vsphere client software (default: true).

Example:

   class vcenter {
     media => 's:\\',
     jvm_memory_option => 'M',
   }
