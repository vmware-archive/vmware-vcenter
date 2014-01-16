Puppet::Type.newtype(:esx_mem) do
  @doc = "Install and configure MEM on ESX Host."

  newproperty(:configure_mem) do
    desc "Confgure MEM  on host."
    newvalues(:'true')
  end

  newproperty(:install_mem) do
    desc "Install MEM  on host."
    newvalues(:'true')
  end

  newparam(:name, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newparam(:host_username) do
    desc "ESX username."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid username."
      end
    end
  end

  newparam(:host_password) do
    desc "ESX password."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid password."
      end
    end
  end

  newparam(:script_executable_path) do
    desc "Script executable path."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid path."
      end
    end
  end

  newparam(:setup_script_filepath) do
    desc "Setup script path."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid setup script path."
      end
    end
  end

  newparam(:vnics) do
    desc "Physical NICs to use for iSCSI."
  end

  newparam(:vnics_ipaddress) do
    desc "IP addresses to use for iSCSI VMkernel ports."
  end

  newparam(:iscsi_vswitch) do
    desc "Name for iSCSI vSwitch."
  end

  newparam(:mtu) do
    desc "MTU for iSCSI vSwitch and VMkernel ports."
    dvalue = '9000'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:iscsi_vmkernal_prefix) do
    desc "Prefix to use for VMkernel port names."
    dvalue = 'iSCSI'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue.to_s
      else
        value.to_s
      end
    end

  end

  newparam(:iscsi_netmask) do
    desc "Netmask to use for iSCSI VMkernel ports."
  end

  newparam(:disable_hw_iscsi) do
    desc "Disable the Hardware iSCSI initiator."
    newvalues(:'true', :'false')
    defaultto(:'false')
  end

  newparam(:storage_groupip) do
    desc "PS Group IP address to add as an iSCSI Discovery Portal."
  end

  newparam(:iscsi_chapuser) do
    desc "CHAP username to use for connecting to volumes on the PS Group IP."
  end

  newparam(:iscsi_chapsecret) do
    desc "CHAP secret to use for connecting to volumes on the PS Group IP."
  end
end
