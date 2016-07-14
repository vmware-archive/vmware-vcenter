provider_path = Pathname.new(__FILE__).parent.parent
require 'rbvmomi'
require File.join(provider_path, 'vcenter')
require 'asm/util'

Puppet::Type.type(:esx_software_update).provide(:esx_software_update, :parent => Puppet::Provider::Vcenter) do
  @doc = "Perform software updates on a desired ESX"

  # Method called by puppet to create a resource i.e. when exists returns false
  def create
    begin
      if @actionable_vibs.length > 0
        # Install all specified VIBs
        reboot_required = false
        installed_vibs = []
        skipped_vibs = []
        @actionable_vibs.each do |vib_url|
          Puppet.debug("Attempting to install the VIB: #{vib_url}")
          install_results = install_vib vib_url
          installed_vibs += install_results[:VIBsInstalled]
          skipped_vibs += install_results[:VIBsSkipped] if install_results[:VIBsSkipped]
          reboot_required ||= install_results[:RebootRequired]
        end
        if installed_vibs.length == @actionable_vibs.length
          Puppet.info("Successfully installed the VIBs")
        elsif installed_vibs.length > 0
          Puppet.info("Successfully installed following VIBs : #{installed_vibs}")
          Puppet.info("Skipped installing following VIBs : #{skipped_vibs}")
          if installed_vibs.length + skipped_vibs.length < @actionable_vibs.length
            raise "Some VIBs failed to install"
          end
        else
          raise "no VIBs installed"
        end
        # Unmount all NFS stores we mounted
        unmount_mounted_nfs_shares
        reboot_and_wait_for_host if reboot_required
      else
        raise "No VIBs to update"
      end
    rescue Exception => e
      unmount_mounted_nfs_shares
      fail "esx_software_update installation failed due to following exception: \n #{e.message}"
    end
  end

  # Method called by puppet to remove a resource i.e. when exists returns true
  def destroy
    begin
      if @actionable_vibs.length > 0
        # Remove all specified VIBs
        reboot_required = false
        removed_vibs = []
        @actionable_vibs.each do |vib_name|
          Puppet.debug("Attempting to remove the VIB: #{vib_name}")
          remove_results = remove_vib vib_name
          removed_vibs += install_results[:VIBsRemoved]
          reboot_required ||= install_results[:RebootRequired]
        end

        if removed_vibs.length == @actionable_vibs.length
          Puppet.info("Successfully removed the VIBs")
        elsif removed_vibs.length > 0
          Puppet.info("Successfully removed following VIBs : #{removed_vibs}")
        else
          raise "no VIBs removed"
        end
        reboot_and_wait_for_host if reboot_required
      end
    rescue Exception => e
      if e.is_a?(Rbvmomi::Fault)
        fail "esx_software_update removal failed due to following exception: \n #{e.message} #{e.fault.errMsg}"
      else
        fail "esx_software_update removal failed due to following exception: \n #{e.message}"
      end
    end
  end

  # Method called by puppet to determine if a resource exists or not
  def exists?
    @actionable_vibs = []     # List of VIBs which are either a) fully qualified paths for VIBs to install,
                              # OR b) VIB package name to install
    @mounted_nfs_shares = {}  # Map of NFS shares that are mounted on the ESX
                              # key: "nfs_hostname:/share" representing NFS mounted share
                              # value: {volume_name i.e. corresponding volume name, new_mount i.e. boolean indicating if it was mounted by us}
    is_install = nil          # Flag to determine if we are in install mode (create) or uninstall mode (destroy)
    existing_vibs = {}        # List of all existing VIBs on the ESX host
    begin
      if resource[:nfs_hostname]
        # Get list of all mounted NFS datastores, and add it to mounted NFS shares
        Puppet.debug("Getting list of mounted NFS datastores...")
        host.esxcli.storage.nfs.list.each do |nfs_store|
          if nfs_store[:Host] && nfs_store[:Share] && nfs_store[:Mounted]
            key = nfs_store[:Host] + ":" + nfs_store[:Share]
            @mounted_nfs_shares[key] = { :volume_name => nfs_store[:VolumeName], :new_mount => false }
            Puppet.debug("Added existing NFS mount #{key} on the ESX host")
          end
        end
      end
      # Get all pre-installed VIBs and save it to our map
      Puppet.debug("Getting list of pre-installed VIBs...")
      host.esxcli.software.vib.get.each do |installed_vib_data|
        if installed_vib_data[:ID]
          existing_vibs[installed_vib_data[:ID]] = true
          Puppet.debug("Found pre-installed VIB #{installed_vib_data[:ID]}")
        end
      end
      vibs = resource[:vibs].is_a?(Array) ? resource[:vibs] : [resource[:vibs]]
      Puppet.debug("VIBs to query : #{vibs}...")
      # The type validation already validates proper format of fields for either install or uninstall
      # To determine the install mode, we simply need to do check if first element hash or not
      is_install = vibs.first.is_a?(Hash)
      vibs.each do |vib_data|
        if !is_install
          # For each VIB data, add the VIB name to the actionable_vibs list
          add_actionable_vib(vib_data)
        else
          # For each VIB data, mount any NFS shares if provided, then check if the VIB is already installed
          # on the ESX host. If not installed, add qualified path to the VIB to actionable_vibs list
          # Fetch VIB info from the source
          qualified_vib_path = setup_fully_qualified_vib_path(vib_data)
          Puppet.debug("Fetching VIB info for #{qualified_vib_path}")
          begin
            vib_source_data = get_source_vib_info(qualified_vib_path)
            # Check if the VIB is already pre-installed. If not, we can add to actionable_vibs list
            if vib_source_data.is_a?(Array)
              if existing_vibs[vib_source_data[0][:ID]]
                Puppet.debug("#{vib_source_data[0][:ID]} is already installed.")
              else
                Puppet.debug("#{vib_source_data[0][:ID]} is not installed")
                add_actionable_vib(qualified_vib_path)
              end
            else
              Puppet.warning("Unexpected VIB source information: #{vib_source_data} is not an Array.")
            end
          rescue Exception => e
            Puppet.error("Failed to get VIB info for #{qualified_vib_path} due to error: #{e.message}")
            Puppet.error("Fault error message: #{e.fault.errMsg}") if e.is_a?(RbVmomi::Fault)
            raise e
          end
        end
      end
    rescue Exception => e
      Puppet.error("Cannot determine if specified VIBs exists due to exception #{e.class}:#{e.message} Backtrace: #{e.backtrace.join("\n")}")
      raise e
    end
    # For install mode: if there are any actionable VIBs, we need to return false (i.e. resource does not exist) so that "create" is invoked by puppet
    # For uninstall mode: if there are any actionable VIBs, we need to return true (i.e. resource exist) so that "destroy" is invoked by puppet
    is_install ? @actionable_vibs.length == 0 : @actionable_vibs.length > 0
  end

  # Helper method to add to list to actionable VIBs
  def add_actionable_vib(path_to_vib)
    Puppet.debug("Adding #{path_to_vib} to list of VIBs for install or uninstall")
    @actionable_vibs.push(path_to_vib)
  end

  # Helper method to reboot a ESX host and wait for it to come back upto desired timeout
  def reboot_and_wait_for_host
    host.RebootHost_Task({:force => false}).wait_for_completion
    Puppet.debug("Waiting upto #{resource[:reboot_timeout]} seconds for host to connect")
    rounds = ((1.0 * (resource[:reboot_timeout] - 180)) / 30).ceil
    sleep 180  # Sleep for 3 minutes to allow reboot initiation request to reflect
    for i in 1..rounds
      begin
        if host.runtime.connectionState == "connected"
          Puppet.debug("Host has rebooted and is connected")
          break
        end
      rescue Exception => ex
        Puppet.debug("Ignoring #{ex} since host is in process of rebooting")
        if ex.is_a?(RbVmomi::Fault) && ex.fault.class.to_s == "NotAuthenticated"
          Puppet.debug("Resetting host connection")
          reset_connection
        end
      end
      sleep 30
    end
  end

  # Get fully qualified path for a given VIB, performing any setup necessary
  #
  # This method is used to perform setup operations like mounting NFS share on ESX with
  # desired volume name and return resulting fully qualified path to the VIB.
  # For HTTP(s), FTP protocols it simply uses whatever VIB path was specified.
  #
  # @param vib_data [Hash]
  # @option vib_data [String] :nfs_share Name of the NFS share on the remote NFS host
  #                            that needs to be mounted (Not required for HTTPs or FTP vib_path)
  #                            Example: /var/nfs/blah1/blah2
  # @option vib_data [String] :vib_path Fully qualified HTTP/FTP path, or relative path to NFS share (including the VIB name)
  #                           Examples:
  #                           1. http://vmwaredepot.dell.com/DEL/5.5/vib20/ASM/foo.vib
  #                           2. some_folder_relative_to_nfs_share/foo.vib
  #                           3. foo.vib (if it is directly on nfs_share folder)
  # @option vib_data [String] :volume_name Volume name to represent the mounted NFS share on ESX
  # @return [String]
  def setup_fully_qualified_vib_path vib_data
    return '' if vib_data.nil?
    if vib_data[:nfs_share].nil?
      # Seems we have fully qualified HTTP(s) or FTP path, use straight-away
      qualified_vib_path = vib_data[:vib_path]
    else
      if resource[:nfs_hostname].nil?
        # If there is no NFS hostname, then seems the specified Share is local to the ESX, use share + VIB as path
        qualified_vib_path = vib_data[:nfs_share] + "/" + vib_data[:vib_path]
      else
        qualified_vib_path = "/vmfs/volumes/" + vib_data[:volume_name] + "/" + vib_data[:vib_path]
        mount_key = resource[:nfs_hostname] + ":" +  vib_data[:nfs_share]
        if @mounted_nfs_shares[mount_key].nil?
          # Need to mount a new NFS store
          if mount_nfs_share(vib_data[:nfs_share], vib_data[:volume_name])
            # Add to mount map
            @mounted_nfs_shares[mount_key] = { :volume_name => vib_data[:volume_name], :new_mount => true }
          end
        end
      end
    end
    qualified_vib_path
  end

  # Esxcli wrapper method to get VIB info for a given VIB on either NFS, HTTP or FTP location
  def get_source_vib_info qualified_vib_path
    # Note: This is odd, the ESX hostagent API can handle arrays, but the VirtualCenter API does not
    if vim.serviceInstance.content.about.apiType == "HostAgent"
      host.esxcli.software.sources.vib.get({:viburl => [qualified_vib_path]})
    else # VirtualCenter
      host.esxcli.software.sources.vib.get({:viburl => qualified_vib_path})
    end
  end

  # Esxcli wrapper method to install a VIB present on either NFS, HTTP or FTP location
  def install_vib qualified_vib_path
    # Note: This is odd, the ESX hostagent API can handle arrays, but the VirtualCenter API does not
    if vim.serviceInstance.content.about.apiType == "HostAgent"
      host.esxcli.software.vib.install(:viburl => [qualified_vib_path])
    else # VirtualCenter
      host.esxcli.software.vib.install(:viburl => qualified_vib_path)
    end
  end

  # Esxcli wrapper method to remove a VIB represented by VIB name
  def remove_vib vib_name
    # Note: This is odd, the ESX hostagent API can handle arrays, but the VirtualCenter API does not
    if vim.serviceInstance.content.about.apiType == "HostAgent"
      host.esxcli.software.vib.remove(:vibname => [vib_name])
    else # VirtualCenter
      host.esxcli.software.vib.remove(:vibname => vib_name)
    end
  end

  # Helper method to mount a given NFS share on ESX as a specified volume_name
  def mount_nfs_share share, volume_name
    begin
      Puppet.debug("Mounting #{share} with volume name #{volume_name}")
      host.esxcli.storage.nfs.add({:host => resource[:nfs_hostname],
                                   :share => share,
                                   :volumename => volume_name})
      Puppet.info("Mounted #{share} with volume name #{volume_name}")
      return true
    rescue RbVmomi::Fault => e
      Puppet.error("Failed to mount #{share} due to error: #{e.message} #{e.fault.errMsg}")
    end
    false
  end

  # Helper method to unmount all NFS shares we mounted (not existing ones)
  def unmount_mounted_nfs_shares
    @mounted_nfs_shares.each do |key, value|
      if value[:new_mount]
        if unmount_nfs_share(value[:volume_name])
          @mounted_nfs_shares.delete(key) # Remove from mount map as well
        end
      end
    end
  end

  # Helper method to unmount a given NFS volume on ESX
  def unmount_nfs_share volume_name
    begin
      Puppet.debug("Unmounting volume name #{volume_name}")
      host.esxcli.storage.nfs.remove({:volumename => volume_name})
      Puppet.info("Unmounted volume name #{volume_name}")
      return true
    rescue RbVmomi::Fault => e
      Puppet.error("Failed to unmount #{volume_name} due to error: #{e.message} #{e.fault.errMsg}")
    end
    false
  end

end
