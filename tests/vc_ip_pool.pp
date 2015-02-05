transport {'vcenter' :
  username => $vc_username,
  password => $vc_password,
  server   => $vc_hostname,
  options  => $vc_options,
}

vc_ip_pool { 'test_pool' :
  ensure 		     => present,
  #ensure 		     => absent,
  #force_destroy 	     => true,
  name    		     => 'default_ippool',
  datacenter                 => $dc1,
  dns_domain 		     => $domain,
  ipv4_config_dns 	     => [$dns1, $dns2],
  ipv4_config_gateway 	     => $gateway,
  ipv4_config_netmask        => $netmask,
  ipv4_config_subnet_address => $subnet,
  network_association        => [ { networkName => $pgname1 }, { networkName => $pgname2 } ],
  dns_search_path            => $searchPath,
  transport 		     => Transport['vcenter']
}
