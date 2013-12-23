# Copyright (C) 2013 VMware, Inc.
import 'data_registervm.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vm_register { $newVM['name']:
  ensure     => $newVM['ensure'],
  transport  => Transport['vcenter'],
  #to rgister vm
  datacenter => $newVM['datacenter'],  
  hostip       => $newVM['hostip'],
  astemplate => $newVM['astemplate'],
  # register vm by this name/ unregister vm of this name
  vmpath_ondatastore  => $newVM['vmpath_ondatastore'], 
  
 }


