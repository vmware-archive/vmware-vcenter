# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_powerpolicy { $esx0['hostname']:
  current_policy => 'static',
  transport      => Transport['vcenter'],
}

esx_powerpolicy { $esx1['hostname']:
  current_policy => 'static',
  transport      => Transport['vcenter'],
}
