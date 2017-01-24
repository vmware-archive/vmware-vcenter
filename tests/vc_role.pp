  transport { 'vcenter':
    username => $username,
    password => $password,
    server   => $vcenter,
    options  => {
      'rev'      => '5.5',
      'insecure' => true
    },
  }

  vc_role { $role_name:
    ensure       => present
#    ensure       => absent,
#    force_delete => true,
    privileges   => $privileges,
    transport    => Transport['vcenter']
  }
