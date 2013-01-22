transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

vc_folder { ['/folder1','/folder1/a','/folder1/a/b']:
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_folder { '/folder2':
  ensure    => present,
  transport => Transport['vcenter'],
}
