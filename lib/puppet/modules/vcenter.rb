require 'rbvmomi'

module Puppet::Modules
  module VCenter
    def find_immediate_parent root_folder, parent_lvs, error_msg
      current_lv = root_folder
      parent_lvs.each do |lv|
        # TODO ASSUMPTION each level is either a Folder (has a find method)
        # or a Datacenter (.hostFolder has a find method)

        # Under the above assumption, if current_lv is doesn't have a find
        # method, we actually want its hostFolder
        unless current_lv.class.method_defined? 'find'
          current_lv = current_lv.hostFolder
        end

        # Go one level deeper.  Raise an error if we can't.
        current_lv = current_lv.find lv
        unless current_lv
          raise Puppet::Error.new error_msg
        end
      end

      if current_lv.is_a? RbVmomi::VIM::Datacenter
        current_lv.hostFolder 
      else
        current_lv
      end
    end
  end
end
