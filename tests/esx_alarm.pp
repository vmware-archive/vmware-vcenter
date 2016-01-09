# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_alarm { "${esx1['hostname']}":
  ensure    => absent,
  host => $esx1['hostname'],
  datacenter => $dc1['name'],
  transport => Transport['vcenter'],
}
