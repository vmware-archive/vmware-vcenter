transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

vc_vm { 'test2':
  path      => '/dc1/192.168.232.240',
  transport => Transport['vcenter'],
}
