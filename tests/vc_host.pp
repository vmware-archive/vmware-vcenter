# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_datacenter { $dc1['name']:
  ensure    => present,
  path      => $dc1['path'],
  transport => Transport['vcenter'],
}

vc_host { $esx1['hostname']:
  ensure    => present,
  path      => $dc1['path'],
  username  => $esx1['username'],
  password  => $esx1['password'],
  transport => Transport['vcenter'],
}
