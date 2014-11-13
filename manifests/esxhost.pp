class vcenter::esxhost (
  $vim,
  $target_esxhost,
  $systemResources
) {

  transport { 'vcenter':
    username => $vim['username'],
    password => $vim['password'],
    server   => $vim['hostname'],
    options  => {
        'insecure' => 'true',
        'rev' => '5.1',
      },
   } ->
 
  esx_system_resource { "systemResource0":
    host            =>  $target_esxhost,
    system_resource =>  $systemResources['resource0']['name'],
    cpu_limit       =>  $systemResources['resource0']['cpuLimit'],
    transport       =>  Transport['vcenter'],
  }
  
}

