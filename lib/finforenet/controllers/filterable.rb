module Finforenet
  module Controllers 
    module Filterable
      extend ActiveSupport::Concern
      
      ERR_AUTH    = "NotAuthorizedAccess"
      ERR_LOGIN   = "LoginInvalid"
      REGEX_EMAIL = Regexp.new('^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$',Regexp::IGNORECASE)
      REGEX_URL   = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
      
      included do
      end

      module ClassMethods
	
      end
      
      module InstanceMethods
	    private
	  
		def random_characters
		  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		  return (0...16).map{ chars[rand(chars.size-1)] }.join
		end
	
      end
      
    end
  end
end
