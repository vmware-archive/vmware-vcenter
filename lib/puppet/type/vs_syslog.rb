Puppet::Type.newtype(:vs_syslog) do
  # http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2003322
  @doc = "Manage vCenter esx hosts syslog config."

  newparam(:host, :namevar => true) do
    desc "Vshield hostname or ip address."
  end

  newproperty(:serverinfo) do
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end
end
