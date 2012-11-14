transport { 'vshield':
  username => 'admin',
  password => 'default',
  server   => '192.168.232.149',
}

vshield_syslog { '192.168.232.149':
  server_info => '192.168.232.2:1000',
  transport   => Transport['vshield'],
}
