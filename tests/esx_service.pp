# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# Cause an refresh:
notify { 'trigger': }

esx_service { "${esx1['hostname']}:ntpd":
  running   => false,
  policy    => 'on',
  transport => Transport['vcenter'],
  subscribe => Notify['trigger'],
}
