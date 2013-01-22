#!/usr/bin/env ruby
require 'pathname'
dir = Pathname.new(__FILE__).parent

begin
  f = File.new(File.join(dir, 'data.yaml'), 'r')
  puts f.read
ensure
  f.close
end
