transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_syslog { '192.168.232.240':
  default_rotate => 8,
  default_size   => 2048,
  log_dir_unique => true,
  transport      => Transport['vcenter'],
}
