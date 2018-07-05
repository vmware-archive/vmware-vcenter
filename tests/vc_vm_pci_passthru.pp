transport { "vcenter":
  username => "administrator@vsphere.local",
  password => "xxxx",
  server   => "vcenter_ip",
  options  => {"insecure" => true},
  provider => "device_file"
}

vc_vm_pci_passthru { "vm_name":
  ensure    => present,
  datacenter => "datacenter_name",
  transport => Transport["vcenter"]
}
