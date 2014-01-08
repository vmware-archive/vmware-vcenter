# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vm_snapshot { 'name':
  vm_name            => "testvm",
  name               => "testsnapshot",
  snapshot_operation => create,
  datacenter         => "DC1",
  transport          => Transport['vcenter'],
}
