transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

vc_vm { 'test2':
  path      => '/dc1',
  memory    => '128',

  transport => Transport['vcenter'],
}
