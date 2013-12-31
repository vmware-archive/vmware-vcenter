import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_fcoe { 'vmnic1':
  ensure         => present,
  host           => "${esx1['hostname']}",
  transport      => Transport['vcenter'],
}