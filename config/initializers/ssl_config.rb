    require 'net/http'
    require 'openssl'

    class Net::HTTP   
      alias_method :origConnect, :connect
      def connect
        begin
          @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        rescue
        end
        origConnect
      end
    end

#Enable it to hack authlogic if not working
Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
