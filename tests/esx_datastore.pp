transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_datastore { '192.168.232.240:nfs_store':
  ensure      => present,
  type        => 'nfs',
  remote_host => '192.168.232.1',
  remote_path => '/Users/nan/src/nodejs',
  transport   => Transport['vcenter'],
}
