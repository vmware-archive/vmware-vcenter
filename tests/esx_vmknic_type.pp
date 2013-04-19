# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_vmknic_type { "${esx1['hostname']}:vmk0" :
  # nic_type  => ['management', 'vmotion', 'faultToleranceLogging'],
  # nic_type  => ['management', 'vmotion'],
  nic_type  => ['management'],
  # nic_type => 'management',
  transport => Transport['vcenter'],
}
