class vcenter::vm_host_rule (
  $vc_username,
  $vc_password,
  $vc_hostname,
  $datacenter,
  $cluster,
  $rule_name,
  $vm_group,
  $vms                    = undef,
  $affine_host_group      = undef,
  $affine_hosts           = undef,
  $anti_affine_host_group = undef,
  $anti_affine_hosts      = undef,
  $enabled                = undef,
  $in_compliance          = undef,
  $mandatory              = undef,
  $transport_options      = {},
  $ensure                 = present,
) {

  transport { "vcenter":
    username => $vc_username,
    password => $vc_password,
    server   => $vc_hostname,
    options  => $transport_options,
  }

  vc_vm_group { $vm_group:
    ensure    => $ensure,
    transport => Transport["vcenter"],
    path      => "/$datacenter/$cluster",
    vms       => $vms, 
    before    => Vc_vm_host_rule[$rule_name]
  }

  if $affine_host_group { 
    vc_host_group { $affine_host_group:
      ensure    => $ensure,
      transport => Transport["vcenter"],
      path      => "/$datacenter/$cluster",
      hosts     => $affine_hosts,
      before    => Vc_vm_host_rule[$rule_name]
    }
  }

  if $anti_affine_host_group { 
    vc_host_group { $anti_affine_host_group:
      ensure    => $ensure,
      transport => Transport["vcenter"],
      path      => "/$datacenter/$cluster",
      hosts     => $anti_affine_hosts,
      before    => Vc_vm_host_rule[$rule_name]
    }
  }

  vc_vm_host_rule { $rule_name:
    ensure                      => $ensure,
    enabled                     => $enabled,
    mandatory                   => $mandatory,
    in_compliance               => $in_compliance,
    vm_group_name               => $vm_group,
    affine_host_group_name      => $affine_host_group,
    anti_affine_host_group_name => $anti_affine_host_group,
    transport                   => Transport["vcenter"],
    path                        => "/$datacenter/$cluster",
  }
}
