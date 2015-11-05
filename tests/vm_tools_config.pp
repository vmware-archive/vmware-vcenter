# Copyright (C) 2014 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# The datacenter and vm name will be extracted from the namevar for unique identification. This will allow for setting the same tools property across multiple VMs while keeping unique puppet resource names.
vm_tools_config { "$dc:$vmname": #'dc1:vm1':
  after_power_on        => 'true',
  after_resume          => 'true',
  before_guest_reboot   => 'true',
  before_guest_shutdown => 'true',
  before_guest_standby  => 'true',
  sync_time_with_host   => 'false',
  tools_upgrade_policy  => 'manual',
  transport             => Transport['vcenter'],
}
