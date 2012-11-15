transport { 'vshield':
  username => 'admin',
  password => 'default',
  server   => '192.168.232.149',
}

vshield_global_config { '192.168.232.149':
  vc_info   => {
    ip_address => '192.168.232.147',
    user_name  => 'root',
    password   => 'vmware',
  },
  time_info => { 'ntp_server' => '192.168.232.1' },
  dns_info  => { 'primary_dns' => '8.8.9.9' },
  transport => Transport['vshield'],
}
