import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_fcoe { "${esx1['hostname']}":
  ensure         => present,
  physical_nic   => 'vmnic0',
  transport      => Transport['vcenter'],
}