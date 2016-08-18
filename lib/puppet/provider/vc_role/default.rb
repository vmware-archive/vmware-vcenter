# Copyright (C) 2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_role).provide(:vc_role, :parent => Puppet::Provider::Vcenter) do

  @doc = "Manage vCenter Roles. http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.wssdk.apiref.doc/vim.AuthorizationManager.Role.html"

  def create
    validate_privileges
    newRole = {
      :name    => resource[:name],
      :privIds => resource[:privileges],
    }
    authorizationManager.AddAuthorizationRole( newRole )
  rescue RbVmomi::Fault => e
    raise Puppet::Error, "Caught RbVmomi while trying to create new role: #{e.message}"
  end

  def destroy
    deleteRole = {
      :roleId     => role.roleId,
      :failIfUsed => failIfUsed
    }
    authorizationManager.RemoveAuthorizationRole( deleteRole )
  rescue RbVmomi::Fault => e
    case e.fault.class.to_s
    when 'RemoveFailed'
      raise Puppet::Error.new( "Unable to remove role '#{resource[:name]}' because it currently has permissions assigned to it. You must either remove the permissions associated with the role or set force_delete to true" )
    else
      raise Puppet::Error, "Caught RbVmomi while trying to create remove role: #{e.message}"
    end
  end

  def exists?
    Puppet.debug "Evaluating '#{resource.inspect}' => #{resource.to_hash}"
    config_is_now
  end

  def config_should
    @config_should ||= {}
  end

  ##### begin standard provider methods #####
  # these methods should exist in all ensurable providers, but content will diff

  def config_is_now
    @config_is_now ||= role 
  end

  def flush
    Puppet.debug "config_is_now is #{config_is_now.inspect}"
    Puppet.debug "config_should is #{config_should.inspect}"
    if @flush_required
      updatedRole = {
        :roleId  => config_is_now.roleId,
        :newName => config_is_now.name,
        :privIds => config_should[:privileges]
      }
      Puppet.debug "Updating role '#{config_is_now.name}'"
      authorizationManager.UpdateAuthorizationRole( updatedRole )
    end
  rescue RbVmomi::Fault => e
    raise Puppet::Error, "Caught RbVmomi error while trying to update role: #{e.message}"
  end

  ##### begin private provider specific methods section #####
  # These methods are provider specific and that can be private

  def privileges
    Puppet.debug "Current privileges: #{config_is_now.privilege.inspect}"
    # Remove default privileges to prevent false updates
    config_is_now.privilege.reject { |p| default_privilege_ids.include? p}
  end

  def privileges=(ids)
    validate_privileges
    @flush_required = true
    config_should[:privileges] = ids
  end

  private

  def authorizationManager
    @authorizationManager ||= vim.serviceContent.authorizationManager
  end

  def role
    authorizationManager.roleList.find { |r| r.name == resource[:name] }
  end

  def valid_privileges
    @valid_privileges ||= authorizationManager.privilegeList.collect { |p| p.privId }
  end

  def validate_privileges
    invalid = resource[:privileges].reject { |p| valid_privileges.include? p}.sort
    raise Puppet::Error, "Invalid privileges: #{invalid.inspect}. Valid values are #{valid_privileges.inspect}" if invalid.nil? || !invalid.empty?
  end

  def failIfUsed
    if resource[:force_delete].to_s.downcase == 'true'
      'false'
    else
      'true'
    end
  end

  def default_privilege_ids
    ['System.Anonymous', 'System.Read', 'System.View']
  end
end

