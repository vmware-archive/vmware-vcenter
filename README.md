# vcenter puppet module

VMware vCenter installation and management

## Installation

Parameters:

* media: vCenter installation software media location.
* sql_media: Microsoft SQL installation software media location.
* username: vcenter service account (default: VCENTER).
* password: vcenter service account password (default: 'vC3nt!2008demo'),
* jvm_memory_option: vcenter sql server size, support S, M, L.
* client: install vsphere client software (default: true).

Example:

    class vcenter {
      media => 's:\\',
      jvm_memory_option => 'M',
    }
