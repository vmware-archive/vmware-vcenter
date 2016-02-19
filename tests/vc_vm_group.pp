import data.pp

transport {'vcenter' :
  username => $vc_username,
  password => $vc_password,
  server   => $vc_hostname,
  options  => $vc_options,
}

vc_vm_group { 'test_vm_group':
#  ensure    => absent,
  transport => Transport["vcenter"],
  path      => "/$datacenter/$cluster",
  vms       => $vms 
}
