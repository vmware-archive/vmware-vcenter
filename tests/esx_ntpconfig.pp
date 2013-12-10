# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_ntpconfig { $esx1['hostname']:
  server    => ['ntp.puppetlabs.com','ntp.puppetlabs.lan'],
  transport => Transport['vcenter'],
}
