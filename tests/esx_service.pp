transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

notify { 'trigger': }

esx_service { "${esx_ip}:ntpd":
  running   => false,
  policy    => 'on',
  transport => Transport['vcenter'],
  subscribe => Notify['trigger'],
}
