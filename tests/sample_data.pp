$vcenter = {
  'username' => 'root',
  'password' => 'vmware',
  'server'   => '192.168.1.1',
  'options'  => { 'insecure' => true }
}

$dc1 = {
  'name' => 'testdc',
  'path' => '/testdc',
}

$esx1 = {
  'username' => 'root',
  'password' => 'password',
  'hostname' => '192.168.1.10',
}
