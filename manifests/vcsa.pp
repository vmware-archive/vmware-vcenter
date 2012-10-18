# vCSA appliance configuration.
define vcenter::vcsa (
  $username      = 'root',     #: vcsa appliance username
  $password      = 'vmware',   #: vcsa appliance password
  $server,                     #: vCSA appliance server name or ip address
  $db_type       = 'embedded',
  $db_server     = undef,
  $db_port       = undef,
  $db_instance   = undef,
  $db_user       = undef,
  $db_password   = undef,
  $capacity      = 'small',    #: inventory accepts small, medium, large
  $java_max_heap = undef       #: manual jmx heap max size configuration
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

  transport { $name:
    username => $username,
    password => $password,
    server   => $server,
  }

  vcsa_eula { $name:
    ensure    => accept,
    transport => Transport[$name],
  } ->

  vcsa_db { $name:
    ensure    => present,
    type      => $db_type,
    server    => $db_server,
    port      => $db_port,
    instance  => $db_instance,
    user      => $db_user,
    password  => $db_password,
    transport => Transport[$name],
  } ->

  vcsa_sso { $name:
    ensure    => present,
    dbtype    => $db_type,
    server    => $db_server,
    port      => $db_port,
    instance  => $db_instance,
    user      => $db_user,
    password  => $db_password,
    transport => Transport[$name],
  } ->

  vcsa_java { $name:
    ensure    => present,
    inventory => $jmx['is'],
    sps       => $jmx['sps'],
    tomcat    => $jmx['tomcat'],
    transport => Transport[$name],
  } ~>

  vcsa_service { 'demo':
    ensure    => running,
    transport => Transport[$name],
  }
}
