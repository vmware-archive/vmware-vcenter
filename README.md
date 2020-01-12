[![Build Status](https://travis-ci.org/vmware/vmware-vcenter.svg?branch=master)](https://travis-ci.org/vmware/vmware-vcenter)

# VMware has ended active development of this project, this repository will no longer be updated.
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

## ESXi resource types
### esx_advanced_options
#### Parameters
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`
* `options`: A hash containing a list of options:
```
options => {
"Vpx.Vpxa.config.log.level"  => "verbose",   # ChoiceOption  default "verbose"
"Config.HostAgent.log.level" => "verbose",   # ChoiceOption  default "verbose"
"Annotations.WelcomeMessage" => "",          # StringOption  default ""
"BufferCache.SoftMaxDirty"   => 15,          # LongOption    default 15
"CBRC.Enable"                => false,       # BoolOption    default false
"Config.GlobalSettings.guest.commands.sharedPolicyRefCount" => 0   # IntOption     default 0
```

### esx_debug
#### Parameters
* `debug`: true, false
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_firewall_ruleset
#### Parameters
* `ensure`: enabled, disabled
* `name`: Name of the firewall ruleset (namevar)
* `host`: ESX host to configure (namevar)
* `path`:  Path to the datacenter where the host resides
* `allowed_hosts`: Accepts a string value of "all" or an array of IP addresses and IP networks with prefixes
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

#### Title pattern

Both `name` and `host` are namevars, by default the title will be used for `name`, but both may be specified in the title as `host:name`

### esx_dnsconfig
#### Parameters
* `address`: ['array','of','dns','values']
* `host_name`: Hostname of ESXi server.
* `domain_name`: Domain name of ESXi server.
* `search_domain`: Search domain of ESXi server.
* `dhcp`: true, false
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`
#### Further Documentation
[VMware Docs](http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fvim.host.DnsConfig.html)

### esx_ntpconfig
#### Parameters
* `server`: ['array','of','ntp','servers']
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_powerpolicy
#### Parameters
* `current_policy`: 'static','dynamic','low'
static = High performance
dynamic = Balanced
low = Low Power
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`


### esx_service
The service name should be in the form of: `ESXi_hostname:<service name`. Eg `esx.example.com:ntpd`
#### Parameters
* `running`: true, false
* `policy`: 'on','off','automatic'
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_syslog
#### Parameters
* `default_rotate`: The maximum number of log files to keep locally on the ESXi host in the configured logDir. Does not affect remote syslog server retention. Defaults to 8
* `default_size`: The maximum size, in kilobytes, of each local log file before it is rotated. Does not affect remote syslog server retention. Defaults to 1024 KB.
* `log_dir`: A location on a local or remote datastore and path where logs are saved to. Has the format `[DatastoreName] DirectoryName/Filename`, which maps to `/vmfs/volumes/DatastoreName/DirectoryName/Filename`. The `[DatastoreName]` is case sensitive and if the specified DirectoryName does not exist, it will be created. If the datastore path field is blank, the logs are only placed in their default location. If `/scratch` is defined, the default is `[]/scratch/log`.
* `log_host`:A remote server where logs are sent using the syslog protocol. If the logHost field is blank, no logs are forwarded. Include the protocol and port, similar to `tcp://hostname:514`
* `log_dir_unique`: A boolean option which controls whether a host-specific directory is created within the configured logDir. The directory name is the hostname of the ESXi host. A unique directory is useful if the same shared directory is used by multiple ESXi hosts. Defaults to false.
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_system_resource
#### Parameters
This resource allows the configuration of system resources of a host that are viewed und er the 'System Resource Allocation' section of the vSphere client
* `host`:
* `system_resource`:
* `cpu_limit`: Can be set to a numerical value representing MHz, or "unlimited"
* `cpu_reservation`:
* `cpu_expandable_reservation`:
* `memory_limit`: Can be set to a numerical value representing MB, or "unlimited"
* `memory_reservation`:
* `memory_expandable_reservation`:
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_timezone
#### Parameters
* `key`: 3 letter time zone. Eg: 'GMT'
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_datastore
Manage vCenter esx hosts' datastore.
The datastore name should be in the form of: `ESXi_hostname:<datastore name>`.      
#### Parameters
* `ensure`: present
* `type`: vmfs, cifs, nfs
* `lun`: LUN number of storage volume.  Specify only for block storage.
* `remote_host`: IP or DNS name of remote host.
* `remote_path`: Path to directory/folder or remote host.
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`



### esx_vmknic_type
Manages ESXi vmknic types - management, vmotion, faultToleranceLogging, or vSphereReplication
The vmknic type should be in the form of: `ESXi_hostname:<name of vmknic>`.
#### Parameters
* `nic_type`: 'faultToleranceLogging', 'management', 'vmotion', 'vSphereReplication'
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`

### esx_license
#### Parameters
* `license_key`: Namevar variable for puppet.
Adds licenses to Vcenter pool.  Does not assign them to managed entities (esxi, vcenter).  Use esx_license_assignment to assign licenses to entities.
#### Usage
```
esx_license { 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
  ensure    => present,
  transport => Transport['vcenter']
}
```
or
```
esx_license { 'mylicense':
  license_key => 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
  ensure      => present,
  transport   => Transport['vcenter']
}
```
### esx_license_assignment
Manage vsphere license assignment. entity_id should be the name of an esx host or vcenter. Licenses can only be assigned to one entity at a time.
#### Parameters
* `entity_id`: Name of ESX or Virtual Center node associated with the license key
* `license_key`: vSphere License Key

## vCenter resource types
### vc_role
#### Parameters
* `transport`: A resource reference to a transport type declared elsewhere. Eg: `Transport['vcenter']`
* `name`: The desired name for the role.
* `privileges`: An array of privilege IDs to be assigned to the role. A list of privileges of privileges can be gathered via the Managed Object Browser (MOB). Simply navigate to https://<vcenter fqdn>/mob/?moid=AuthorizationManager&doPath=privilegeList. Use the privId value to add the privilege to the role.
* `force_delete`: By default, a role will not be deleted if user or group permissions are associated with it. If force_delete is set to true, then the role will be deleted even if there are associated permissions
```
vc_role { 'Role Admin':
  ensure     => present,
  privileges => [ 'Authorization.ModifyRoles', 'Authorization.ReassignRolePermissions', 'Authorization.ModifyPermissions' ],
  transport  => Transport['vcenter']
}
```
or
```
vc_role { 'Role Admin':
  ensure       => absent,
  force_delete => true,
  transport    => Transport['vcenter']
}
```
