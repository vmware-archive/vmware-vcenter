# VMware vCenter module

This module manages resources in VMware vCenter such as folders, datacenter,
ESX host and clusters.

## Description

VMware vCenter can be deployed either via an [virtual appliance (vmware-vcsa
module)](https://github.com/puppetlabs/vmware-vcsa) or installed on a windows
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
