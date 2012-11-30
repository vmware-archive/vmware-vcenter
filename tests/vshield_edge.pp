transport { 'vshield':
  username => 'admin',
  password => 'default',
  server   => '192.168.232.149',
}

transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

vshield_edge { '192.168.232.149:test2':
  ensure     => present,
  datacenter_name => 'dc1',
  compute    => 'clu1',
  enable_aesni => false,
  enable_fips  => false,
  enable_tcp_loose => false,
  vse_log_level => 'info',
  firewall => {
    default_policy => {
      action => 'accept',
      logging_enabled => false,
    }
  },
  transport  => Transport['vshield'],
}
