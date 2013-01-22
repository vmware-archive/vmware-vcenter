transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

esx_datastore { "${esx_ip}:nfs_store":
  ensure      => present,
  type        => 'nfs',
  remote_host => $nfs_host,
  remote_path => $nfs_mount,
  transport   => Transport['vcenter'],
}
