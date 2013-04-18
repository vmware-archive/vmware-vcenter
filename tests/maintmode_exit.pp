# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_maintmode { $esx1['hostname']:
  ensure                    => absent,
  timeout                   => 0,
  transport                 => Transport['vcenter'],
  evacuate_powered_off_vms  => true,
}
