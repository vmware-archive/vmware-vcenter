# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

$ensure_mm = absent

transport { 'esx1':
  username => $esx1['username'],
  password => $esx1['password'],
  server   => $esx1['hostname'],
  options  => $vcenter['options'],
}
transport { 'esx2':
  username => $esx2['username'],
  password => $esx2['password'],
  server   => $esx2['hostname'],
  options  => $vcenter['options'],
}
transport { 'esx3':
  username => $esx3['username'],
  password => $esx3['password'],
  server   => $esx3['hostname'],
  options  => $vcenter['options'],
}

esx_maintmode { "${esx1['hostname']}:X":
  ensure                    => $ensure_mm,
  timeout                   => 0,
  transport                 => Transport['esx1'],
} ~>
esx_maintmode { "${esx2['hostname']}:X":
  ensure                    => $ensure_mm,
  timeout                   => 0,
  transport                 => Transport['esx2'],
} ~>
esx_maintmode { "${esx3['hostname']}:X":
  ensure                    => $ensure_mm,
  timeout                   => 0,
  transport                 => Transport['esx3'],
}
