transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_timezone { '192.168.232.240':
  key       => 'EST',
  transport => Transport['vcenter'],
}
