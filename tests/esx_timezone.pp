import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_timezone { $esx1['hostname']:
  key       => 'EST',
  transport => Transport['vcenter'],
}
