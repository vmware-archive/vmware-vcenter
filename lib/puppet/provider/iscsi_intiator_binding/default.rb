provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require 'asm/util'

Puppet::Type.type(:iscsi_intiator_binding).provide(:default, :parent => Puppet::Provider::Vcenter) do
  @doc = "Binding the HBA to VMkernel nic."
  def create
    #Binding the HBA to VMkernel nic.

    Puppet.notice "Binding the HBA to VMkernel nic."

    vmk_nics = resource[:vmknics]

    vmk_nic_arr = vmk_nics.split(' ')

    for each_vmk_nic in vmk_nic_arr
      begin
        result = ASM::Util.run_command("env", "VI_PASSWORD=%s" % get_host_password,
                                       resource[:script_executable_path],
                                       "--username", resource[:host_username],
                                       "-s", resource[:host_name],
                                       "iscsi", "networkportal", "add",
                                       "--nic", each_vmk_nic,
                                       "--adapter", resource[:vmhba])
        flag = result.exit_status
      rescue Exception => e
        flag = 1  # [XXX] the status handling should be simpler
        Puppet.err(e.message)
      end
      if flag.eql?(0)
        Puppet.notice "HBA '#{resource[:vmhba]}' is bind to VMkernel nic '#{each_vmk_nic}'."
      else
        Puppet.err("Failed to bind HBA and VMK: #{result.stdout}; #{result.stderr}") if result
        fail "Unable to bind HBA '#{resource[:vmhba]}' to VMkernel nic '#{each_vmk_nic}'."
      end
    end
  end

  def destroy
    #Unbind the HBA to VM kernal nic.
    Puppet.notice "Unbind the HBA to VMkernel nic."

    vmk_niks = resource[:vmknics]

    vmk_nik_arr = vmk_niks.split(' ')

    for each_vmk_nic in vmk_nik_arr
      begin
        result = ASM::Util.run_command("env", "VI_PASSWORD=%s" % get_host_password,
                                       resource[:script_executable_path],
                                       "--username", resource[:host_username],
                                       "-s", resource[:host_name],
                                       "iscsi", "networkportal", "remove",
                                       "--nic", each_vmk_nic,
                                       "--adapter", resource[:vmhba])
        flag = result.exit_status
      rescue Exception => e
        flag = 1
        Puppet.err(e.message)
      end
      if flag.eql?(0)
        Puppet.notice "HBA '#{resource[:vmhba]}' is unbind from VMkernel nic '#{each_vmk_nic}'."
      else
        Puppet.err("Failed to unbind HBA and VMK: #{result.stdout}; #{result.stderr}") if result
        fail "Unable to unbind HBA '#{resource[:vmhba]}' from VMkernel nic '#{each_vmk_nic}'."
      end
    end
  end

  # Check whether HBA is mapped to VMkernel nic.
  def exists?
    is_binded
  end

  def is_binded
    result = ASM::Util.run_command("env", "VI_PASSWORD=%s" % get_host_password,
                                   resource[:script_executable_path],
                                   "--username", resource[:host_username],
                                   "-s", resource[:host_name],
                                   "iscsi", "networkportal", "list",
                                   "--adapter", resource[:vmhba])
    flag = result.exit_status
    if flag != 0
      err_content = result.stderr
      Puppet.err err_content
    else
      content = result.stdout
      if (/(?i:Error|failed|SOAP|Enter maintenance mode|Could not find requested datastore|called at|pm line|does not exist|Could not bind)/.match(content))
        Puppet.err content
        flag = 1
      elsif (/(?i:Vmknic:\s+)/.match(content))
        # It will be array of Array. Example: actual_binded_vmk_nics_arr : [["vmk1"], ["vmk2"]]
        actual_binded_vmk_nics_arr = content.scan(/Vmknic:\s+(?<match>.*)/)
        Puppet.notice "Actual binded VMKernel nic : #{actual_binded_vmk_nics_arr}"

        binded_vmk_nics_arr = []
        for item in actual_binded_vmk_nics_arr
          binded_vmk_nics_arr.push(item[0])
        end

        # Binded VMKernel nic : [["vmk1"], ["vmk2"]]
        Puppet.notice "Binded VMKernel nic : #{binded_vmk_nics_arr}"

        input_vmk_nics = resource[:vmknics]
        Puppet.notice "Input VMKernel nic : #{input_vmk_nics}"

        input_vmk_nics_arr = input_vmk_nics.split(' ')
        Puppet.notice "input_vmk_nics_arr : #{input_vmk_nics_arr}"
        Puppet.notice "binded_vmk_nics_arr : #{binded_vmk_nics_arr}"

        if ( binded_vmk_nics_arr.uniq.sort == input_vmk_nics_arr.uniq.sort )
          flag = 0
        else
          resource[:vmknics] = (input_vmk_nics_arr - binded_vmk_nics_arr).uniq.join(" ")
          flag = 1
        end
      else
        flag = 1
      end
    end
    if flag.eql?(0)
      Puppet.info "HBA is already bind to VMkernel."
      return true
    else
      Puppet.notice "HBA is not bind to VMKernel"
      return false
    end
  end

  private
  def get_host_password
    resource[:host_password]
  end

end
