import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Vc_folder {
  transport => Transport['vcenter'],
}

# verify autorequire:
vc_folder { [ '/folder1',
              '/folder1/a',
              '/folder1/a/b'
            ]:
  ensure    => present,
}

vc_folder { '/folder2':
  ensure    => absent,
}
