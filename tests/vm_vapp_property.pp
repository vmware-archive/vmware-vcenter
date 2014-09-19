# Copyright (C) 2014 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# The datacenter, vm name and user visible property label will be extracted from the namevar for unique identification. This will allow for setting the same vApp property across multiple VMs while keeping unique puppet resource names.
vm_vapp_property { "$dc:$vmname:$label": #'dc1:vm1:newProperty':
  ensure            => present,
  category          => 'Application',
  description       => 'A test property created by Puppet',
  id                => 'testproperty',
  type              => 'string(5..10)',
  user_configurable => 'true',
  value             => 'new string',
  transport         => Transport['vcenter'],
}
