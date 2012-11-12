transport { 'vshield':
  username => 'admin',
  password => 'default',
  server   => '192.168.232.149',
}

vs_syslog { '192.168.232.149':
  serverinfo => '192.168.232.1:1000',
  transport  => Transport['vshield'],
}
