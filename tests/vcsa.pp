vcenter::vcsa { 'demo':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
  db_type  => 'embedded',
  capacity => 'm',
}
