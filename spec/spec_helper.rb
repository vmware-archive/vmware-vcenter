require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

$:.unshift File.dirname(__FILE__) + "/fixtures/modules/vmware_lib/lib"

RSpec.configure do |config|
  config.mock_framework = :rspec
end

