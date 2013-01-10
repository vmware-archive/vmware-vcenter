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

vshield_ipset { 'demo':
  value  => [ '10.10.10.1', '10.1.1.2', '10.1.1.1' ],
  scope_name => 'dc1',
  scope_type => 'datacenter',
  transport => Transport['vshield'],
}

vshield_ipset { 'demo2':
  ensure    => absent,
  value  => [ '10.10.10.1' ],
  scope_name => 'dc1',
  scope_type => 'datacenter',
  transport => Transport['vshield'],
}
