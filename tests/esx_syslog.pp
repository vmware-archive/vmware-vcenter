import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_syslog { $esx1['hostname']:
  default_rotate => 8,
  default_size   => 2048,
  log_dir_unique => true,
  transport      => Transport['vcenter'],
}
