# Datacenter can nest datacenters
vc_datacenter { 'dc1':
  path       => '/dc1',
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}

# illegal to have nested datacenter:
#vc_datacenter { 'dc2':
#  path       => '/dc1/dc2',
#  ensure     => present,
#  connection => 'root:vmware@192.168.232.147',
#}

vc_folder { '/dc1/sub_folder1':
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}

vc_folder { '/folder':
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}

vc_datacenter{ '/folder/dc3':
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}

vc_folder { '/folder/sub_folder2':
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}

vc_cluster { '/dc1/clu1':
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}

vc_cluster { '/folder/dc3//clu2':
  ensure     => present,
  connection => 'root:vmware@192.168.232.147',
}
