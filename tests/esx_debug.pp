transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

esx_debug { $esx_ip:
  debug     => true,
  transport => Transport['vcenter'],
}
