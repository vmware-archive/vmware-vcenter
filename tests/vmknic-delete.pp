# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vcenter::vmknic { "${esx1['hostname']}:vmk1":
  ensure    => absent,
  transport => Transport['vcenter'],
}
