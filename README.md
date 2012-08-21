# VMware vCenter module for Puppet

This module deploys VMware vCenter and manages folders, datacenter, ESX host and clusters.

## Installation

The vCenter module depends on the following modules:

* [puppetlabs-registry](https://github.com/puppetlabs/puppetlabs-registry)
* [puppetlabs-mssql](https://github.com/puppetlabs/puppetlabs-mssql)

The modules can be installed via puppet module tool (require [version 2.7.14+](http://docs.puppetlabs.com/puppet/2.7/reference/modules_installing.html)):

    puppet module install puppetlabs/vcenter
    Preparing to install into /Users/nan/.puppet/modules ...
    Downloading from http://forge.puppetlabs.com ...
    Installing -- do not interrupt ...
    /Users/nan/.puppet/modules
    └─┬ puppetlabs-vcenter (v0.1.0)
      ├─┬ puppetlabs-mssql (v0.1.0)
      │ └── puppetlabs-dism (v0.1.0)
      └── puppetlabs-registry (v0.1.1)

## Usage

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

If you already have vCenter deployed or are using vCSA, rbvmomi package is the only dependency for vCenter resources:

    package { 'rbvmomi':
      ensure   => present,
      provider => 'gem',
    }

    Vc_folder {
      require => Pakcage['rbvmomi'],
    }
    ...
    Vc_host {
      require => Pakcage['rbvmomi'],
    }

### vc_folder

Manages vCenter folders.

    vc_folder { 'lab1':
      path       => '/stumptown_lab1', # namevar
      ensure     => present,
      connection => 'administrator:puppet@vcenter.puppetlabs.lan',
    }


### vc_datacenter

Manages vCenter datacenter.

    vc_datacenter { 'dc1':
      path       => '/stumptown_lab1/datacenter1', # namevar
      ensure     => present,
      connection => 'administrator:puppet@vcenter.puppetlabs.lan',
    }

### vc_cluster

Manages vCenter cluster.

    vc_cluster { 'cl1':
      path       => '/stumptown_lab1/datacenter1/cluster1', # namevar
      ensure     => present,
      connection => 'administrator:puppet@vcenter.puppetlabs.lan',
    }

### vc_host

Manages vCenter host.

    vc_cluster { '192.168.1.1':
      path       => '/stumptown_lab1/datacenter1/cluster1', # namevar
      ensure     => present,
      username   => 'root',  # ESX host username
      password   => 'demo1', # ESX host password
      connection => 'administrator:puppet@vcenter.puppetlabs.lan',
    }

## Export and Collect vc_host resources:

In puppet.conf enable [storeconfig](http://projects.puppetlabs.com/projects/1/wiki/Using_Stored_Configuration) to support [export resources](http://docs.puppetlabs.com/guides/exported_resources.html) on the Puppet master. The following section is an example for mysql, see documentation other databases such as puppetdb.

    [master]
      storeconfigs         = true
      storeconfigs_backend = mysql
      dbuser               = puppet
      dbpassword           = password
      dbserver             = master.puppetlabs.local

The provision host can export vc_host resources to be managed by vCenter controlled by puppet:

    @@vc_host { '192.168.1.1':
      ensure   => 'present',
      username => 'root',
      password => 'demo1',
      tag      => 'beaker',
    }

On the puppet master specify where these tags get collected for the vCenter system.

    node vcenter.puppetlabs.local {
      vc_folder { '/lab':
        ensure => present,
      }

      vc_datacenter { [ '/lab/ny', '/lab/ca' ]:
        ensure => present,
      }

      vc_cluster { [ '/lab/ny/kermit', '/lab/ca/beaker' ]:
        ensure => present,
      }

      # Collect resource specify path and connection for vc_host:
      Vc_host <<| tag=='kermit' |>> {
        ensure     => present,
        path       => '/lab/ny/kermit',
        connection => 'administrator:vmware@192.168.72.100',
      }

      Vc_host <<| tag=='dc2' |>> {
        ensure     => present,
        path       => '/lab/ca/beaker',
        connection => 'administrator:vmware2@192.168.72.100',
      }
    }
