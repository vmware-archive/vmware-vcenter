import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_fcoe { "${esx1['hostname']}:vmnic1":
  ensure         => present,
  path         => '<Datacenter_path>',
  transport      => Transport['vcenter'],
}