import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_connection_wait { $esx1['hostname']:
  ensure      => present,
  init_sleep  => 300,
  max_wait    => 600,
  transport   => Transport['vcenter'],
}
