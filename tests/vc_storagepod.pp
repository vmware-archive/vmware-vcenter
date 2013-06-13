import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_storagepod {'ds-cluster':
  ensure     => present,
  datacenter => 'dev-dc',
  transport  => Transport['vcenter'],
  datastores => ['esx-lun0', 'esx-lun1'],
}
