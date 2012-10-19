transport { 'demo':
  username => 'root',
  password => 'vmware',
  server   => '192.168.101.157',
}

vcsa_eula { 'demo':
  ensure    => accept,
  transport => Transport['demo'],
}
