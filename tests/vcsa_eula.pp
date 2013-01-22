transport { 'demo':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

vcsa_eula { 'demo':
  ensure    => accept,
  transport => Transport['demo'],
}
