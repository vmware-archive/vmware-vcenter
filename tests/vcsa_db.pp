transport { 'demo':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

vcsa_db { 'demo':
  ensure    => present,
  type      => 'embedded',
  transport => Transport['demo'],
}
