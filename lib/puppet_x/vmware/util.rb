module PuppetX
  module VMware
    module Util
      def self.camelize(snake_case, first_letter = :upper)
        case first_letter
        when :upper
          snake_case.to_s.gsub(/\/(.?)/){ "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
        when :lower
          snake_case.to_s[0].chr + camelize(snake_case)[1..-1]
        end
      end
    end
  end
end
