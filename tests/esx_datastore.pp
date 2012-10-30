transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_datastore { '192.168.232.240:nfs_store':
  ensure     => absent,
  type       => 'nfs',
  remotehost => '192.168.232.1',
  remotepath => '/Users/nan/src/nodejs',
  transport  => Transport['vcenter'],
}
