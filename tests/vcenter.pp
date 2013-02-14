# Copyright (C) 2013 VMware, Inc.
transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

vc_datacenter { 'dc1':
  path      => '/dc1',
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_folder { '/dc1/sub_folder1':
  ensure    => absent,
  transport => Transport['vcenter'],
}

vc_folder { '/folder':
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_folder { '/folderx':
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_datacenter{ '/folder/dc3':
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_folder { '/folder/sub_folder2':
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_cluster { '/dc1/clu1':
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_cluster { '/folder/dc3/clu2':
  ensure    => present,
  transport => Transport['vcenter'],
}
