Puppet::Type.newtype(:esx_syslog) do
  # http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2003322
  @doc = "Manage vCenter esx hosts syslog config."

  newparam(:host, :namevar => true) do
    desc "ESX hostname or ip address."
  end

  newproperty(:log_dir) do
    desc "A location on a local or remote datastore and path where logs are saved to. Has the format [DatastoreName] DirectoryName/Filename, which maps to /vmfs/volumes/DatastoreName/DirectoryName/Filename. The [DatastoreName] is case sensitive and if the specified DirectoryName does not exist, it will be created. If the datastore path field is blank, the logs are only placed in their default location. If /scratch is defined, the default is []/scratch/log."
  end

  newproperty(:log_host) do
    desc "A remote server where logs are sent using the syslog protocol. If the logHost field is blank, no logs are forwarded. Include the protocol and port, similar to tcp://hostname:514"
  end

  newproperty(:log_dir_unique) do
    desc "A boolean option which controls whether a host-specific directory is created within the configured logDir. The directory name is the hostname of the ESXi host. A unique directory is useful if the same shared directory is used by multiple ESXi hosts. Defaults to false."
    newvalues(:true,:false)
    defaultto(false)
  end

  newproperty(:default_rotate) do
    desc "The maximum number of log files to keep locally on the ESXi host in the configured logDir. Does not affect remote syslog server retention. Defaults to 8."
    newvalues(/\d+/)
    defaultto(8)

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:default_size) do
    desc "The maximum size, in kilobytes, of each local log file before it is rotated. Does not affect remote syslog server retention. Defaults to 1024 KB."
    newvalues(/\d+/)
    defaultto(1024)

    munge do |value|
      Integer(value)
    end
  end

  autorequire(:vc_host) do
    # autorequire esx host.
    self[:name]
  end

  autorequire(:esx_datastore) do
    # autorequire datastore from log_dir
    if self[:log_dir]
      ds = self[:log_dir].match(/\[([^\]]+)\](.*)/)[1]
      "#{self[:name]}:#{ds}"
    end
  end
end
