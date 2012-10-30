transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_debug { '192.168.232.240':
  debug     => true,
  transport => Transport['vcenter'],
}
