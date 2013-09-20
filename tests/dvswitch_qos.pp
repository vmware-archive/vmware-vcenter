# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => "${vcenter['username']}",
  password => "${vcenter['password']}",
  server   => "${vcenter['server']}",
  options  => $vcenter['options'],
}

vc_dvswitch_pool { "${dc1['path']}/dvs1:nfs":
  level => 'custom',
  shares => 97,
  priority_tag => 7,
  transport => Transport['vcenter'],
}
