# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Vc_datacenter {
  transport => Transport['vcenter'],
}

vc_datacenter { $dc1['name']:
  ensure    => present,
  path      => $dc1['path']
}

vc_datacenter { $dc2['name']:
  ensure    => absent,
  path      => $dc2['path']
}
