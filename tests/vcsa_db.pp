transport { 'demo':
  username => 'root',
  password => 'vmware',
  server   => '192.168.101.157',
}

vcsa_db { 'demo':
  ensure    => present,
  type      => 'embedded',
  transport => Transport['demo'],
}
