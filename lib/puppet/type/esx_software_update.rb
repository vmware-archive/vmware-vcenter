Puppet::Type.newtype(:esx_software_update) do
  @doc = "Perform software updates on a desired ESX over NFS, HTTP(s), or FTP"

  ensurable

  newparam(:vibs) do
    desc "Array of VIBs. For installation, each array element is a hash of instance_id, vib_path, nfs_share, volume_name (Note: For HTTP(s) or FTP, provide only fully qualified vib_path). For un-installation, each array element is a string."
    validate do |value|
      if value.is_a?(Array)
        install_mode = value.all? {|v| v.is_a?(Hash) && !v[:vib_path].nil? && !v[:vib_path].empty? }
        uninstall_mode = value.all? {|v| v.is_a?(String) && !v.nil? && !v.empty? }
        unless uninstall_mode
          value.each do |v|
            if !v.is_a?(Hash) || !v[:vib_path] || v[:vib_path].empty? || !v["instance_id"] || v["instance_id"].empty?
              raise ArgumentError, "Invalid install format for one of the array elements"
            end
          end
        end
      elsif value.is_a?(Hash)
        if !value.is_a?(Hash) || !value[:vib_path] || value[:vib_path].empty? || !value["instance_id"] || value["instance_id"].empty?
          raise ArgumentError, "Invalid install format"
        end
      elsif value.is_a?(String)
        raise ArgumentError, "Invalid uninstall format" if value.nil? && !value.empty?
      else
        raise ArgumentError, "Invalid type"
      end
    end
  end

  newparam(:nfs_hostname) do
    desc "Host name for NFS server where the VIB contents are available"
    validate do |value|
      if value.nil? || value.strip.length == 0
        raise ArgumentError, "Invalid name or IP of the NFS host."
      end
    end
  end

  newparam(:reboot_timeout) do
    desc "Timeout for host to complete reboot. Defaults to 180 seconds."
    newvalues(/\d+/)
    defaultto(180)

    munge do |value|
      Integer(value)
    end
  end

  newparam(:no_sign_check) do
    desc "Parameter to allow un-signed VIBs to be installed on the server."
    newvalues(true, false)
    defaultto(false)
  end

  newparam(:host, :namevar => true) do
    desc "The ESX host"
    validate do |value|
      if value.nil? || value.strip.length == 0
        raise ArgumentError, "Invalid name or IP of the host."
      end
    end
  end

end
