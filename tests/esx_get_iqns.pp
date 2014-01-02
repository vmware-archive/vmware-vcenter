import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_get_iqns { "get_iqns":
  host	       => '172.16.103.189',
  hostusername => 'root',
  hostpassword => 'iforgot@123', 
  transport    => Transport['vcenter'], 
}
