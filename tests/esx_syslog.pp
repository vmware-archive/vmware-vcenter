transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

esx_syslog { $esx_ip:
  default_rotate => 8,
  default_size   => 2048,
  log_dir_unique => true,
  transport      => Transport['vcenter'],
}
