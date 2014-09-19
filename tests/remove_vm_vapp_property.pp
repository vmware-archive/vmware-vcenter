# Copyright (C) 2014 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# The datacenter, vm name and user visible property label will be extracted from the namevar for unique identification. This will allow for setting the same vApp property across multiple VMs while keeping unique puppet resource names.
vm_vapp_property { 'dc1:vm1:newProperty':
  ensure      => absent,
  transport   => Transport['vcenter'],
}
