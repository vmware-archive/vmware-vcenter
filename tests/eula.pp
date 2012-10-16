vcsa_transport { 'demo':
  username => 'root',
  password => 'vmware',
  server   => '192.168.101.157',
}

vcsa_eula { 'demo':
  ensure    => accept,
  transport => Vcsa_transport['demo'],
}

#vcsa_db { 'demo':
#  type => 'embedded',
#
#VC_DB_TYPE=
#VC_DB_SERVER=
#VC_DB_SERVER_PORT=
#VC_DB_INSTANCE=
#VC_DB_USER=
#VC_CFG_RESULT=0
#
