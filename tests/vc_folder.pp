transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

vc_folder { ['/folder1','/folder1/a','/folder1/a/b']:
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_folder { '/folder2':
  ensure    => present,
  transport => Transport['vcenter'],
}
