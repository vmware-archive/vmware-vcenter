module PuppetX
  module VMware
    module Util
      def self.camelize(snake_case, first_letter_upcase = true)
        if first_letter_upcase
          snake_case.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
        else
          snake_case[0].chr + camelize(snake_case)[1..-1]
        end
      end
    end
  end
end

class String
  def camelize(first_letter = :lower)
    case first_letter
    when :upper
      PuppetX::VMware::Util.camelize(self, true)
    when :lower
      PuppetX::VMware::Util.camelize(self, false)
    else
      self
    end
  end
end
