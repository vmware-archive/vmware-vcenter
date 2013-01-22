transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

esx_ntpconfig { $esx_ip:
  server    => $esx_ntp_server,
  transport => Transport['vcenter'],
}
