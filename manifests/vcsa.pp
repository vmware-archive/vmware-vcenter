define vcenter::vcsa(
  # vCSA connectivity:
  $username = 'root',
  $password = 'vmware',
  $server,
  # database settings:
  $db_type     = 'embedded',
  $db_server   = undef,
  $db_port     = undef,
  $db_instance = undef,
  $db_user     = undef,
  $db_password = undef,

  $capacity      = 'small', #: accepts small, medium, large
  $java_max_heap = undef    #: user can specify JMX size.
) {

  case $capacity {
    's', 'small': {
      $jmx = {}
      $jmx['tomcat'] = 1024
      $jmx['is']     = 2048
      $jmx['sps']    = 512
    }
    'm', 'medium': {
      $jmx = {}
      $jmx['tomcat'] = 2048
      $jmx['is']     = 4096
      $jmx['sps']    = 1024
    }
    'l', 'large': {
      $jmx = {}
      $jmx['tomcat'] = 3072
      $jmx['is']     = 6144
      $jmx['sps']    = 2048
    }
    default: {
      $jmx = $java_max_heap
    }
  }

  vcsa_transport { $name:
    username => $username,
    password => $password,
    server   => $server,
  }

  vcsa_eula { $name:
    ensure    => accept,
    transport => Vcsa_transport[$name],
  } ->

  vcsa_db { $name:
    ensure    => present,
    type      => $db_type,
    server    => $db_server,
    port      => $db_port,
    instance  => $db_instance,
    user      => $db_user,
    password  => $db_password,
    transport => Vcsa_transport[$name],
  } ->

  vcsa_java { $name:
    ensure    => present,
    inventory => $jmx['is'],
    sps       => $jmx['sps'],
    tomcat    => $jmx['tomcat'],
    transport => Vcsa_transport[$name],
  } ~>

  vcsa_service { 'demo':
    ensure    => running,
    transport => Vcsa_transport[$name],
  }
}
