# Copyright (C) 2013 VMware, Inc.
import 'data_registervm.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vm_register { $newVM['name']:
  ensure             => $newVM['ensure'],
  transport          => Transport['vcenter'],
  datacenter         => $newVM['datacenter'],
  hostip             => $newVM['hostip'],
  astemplate         => $newVM['astemplate'],
  vmpath_ondatastore => $newVM['vmpath_ondatastore'],
}

