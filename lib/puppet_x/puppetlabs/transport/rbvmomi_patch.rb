# Here we monkey-patch classes to workaround issues in public rbvmomi

RbVmomi::VIM::DynamicTypeMgrManagedTypeInfo.send(:alias_method, :__toRbvmomiTypeHash, :toRbvmomiTypeHash)
RbVmomi::VIM::DynamicTypeMgrManagedTypeInfo.send(:define_method, :toRbvmomiTypeHash) do
  {
    self.wsdlName => {
      'kind' => 'managed',
      'type-id' => self.name,
      'base-type-id' => self.base.first,
      'props' => self.property.map do |prop|
        {
          'name' => prop.name,
          'type-id-ref' => prop.type.gsub("[]", ""),
          'is-array' => (prop.type =~ /\[\]$/) ? true : false,
          'is-optional' => prop.annotation.find{|a| a.name == "optional"} ? true : false,
          'version-id-ref' => prop.version,
        }
      end,
      'methods' => Hash[
        self.method.map do |method|
          result = method.returnTypeInfo
          unless result
            puts "#{method.name} does not have a valid return type..."
          end

          [method.wsdlName,
           {
             'params' => method.paramTypeInfo.map do |param|
               {
                 'name' => param.name,
                 'type-id-ref' => param.type.gsub("[]", ""),
                 'is-array' => (param.type =~ /\[\]$/) ? true : false,
                 'is-optional' => param.annotation.find{|a| a.name == "optional"} ? true : false,
                 'version-id-ref' => param.version,
               }
             end,
             'result' => result.nil? ? result : {  # This is the only line we monkey-patch from original implementation
               'name' => result.name,
               'type-id-ref' => result.type.gsub("[]", ""),
               'is-array' => (result.type =~ /\[\]$/) ? true : false,
               'is-optional' => result.annotation.find{|a| a.name == "optional"} ? true : false,
               'version-id-ref' => result.version,
             }
           }
          ]
        end
      ]
    }
  }
end

# Monkey-patch RbVmomi::VIM::close method
#
# Seems current implementation of vim.close does not logout session gracefully, rather results in a
# ManagedObjectNotFound exception and gets ignored silently. See https://github.com/vmware/rbvmomi/issues/101 for
# details. To fix this problem, we override the base implementation to do the appropriate logout operation, and
# then delegate to original implementation
RbVmomi::VIM.send(:alias_method, :__close, :close)
RbVmomi::VIM.send(:define_method, :close) do
  # @todo Remove this patch once above issue is fixed in public rbvmomi gem
  begin
    self.serviceContent.sessionManager.Logout

    self.__close
  rescue
    puts "Failed to close VIM session %s:%s" % [$!.class, $!.message]
  end
end

# Patch for RbVmomi::VIM::ReflectManagedMethodExecuter::execute method
#
# Seems current implementation of execute only supports esxi versions greater than 6.5. This
# patch will overide execute method and supports esxi versions 6 and above
RbVmomi::VIM::ReflectManagedMethodExecuter.send(:define_method, :execute) do |moid, method, args|
  soap_args = args.map do |k, v|
    VIM::ReflectManagedMethodExecuterSoapArgument.new.tap do |soap_arg|
      soap_arg.name = k
      xml = Builder::XmlMarkup.new :indent => 0
      _connection.obj2xml xml, k, :anyType, false, v
      soap_arg.val = xml.target!
    end
  end
  result = ExecuteSoap(:moid => moid, :version => 'urn:vim25/6.0',
                       :method => method, :argument => soap_args)
  if result
    _connection.deserializer.deserialize Nokogiri(result.response).root, nil
  else
    nil
  end
end
