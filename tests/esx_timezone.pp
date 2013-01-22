transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

esx_timezone { $esx_ip:
  key       => 'EST',
  transport => Transport['vcenter'],
}
