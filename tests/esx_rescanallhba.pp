# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_rescanallhba { 'host':
  host      => '172.16.103.95',
  ensure    => present,
  path      => "/AS1000DCTest123/asmcluster",
  transport => Transport['vcenter'],
}
