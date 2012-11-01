transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_syslog { '192.168.232.240':
  defaultrotate => 8,
  defaultsize   => 2048,
  transport     => Transport['vcenter'],
}
