module Finforenet
  module Controllers 
    module Responder
      extend ActiveSupport::Concern
      
      included do
      end

      module ClassMethods
      end
      
      module InstanceMethods
	
	private 
	
	  def error_object(message = "Invalid Access")
	    {:error => message}
	  end

	  def accident_alert(message)
	    respond_to do |format|
		  respond_to_do(format, error_object(message))
	    end
	  end
	  
	  def display_rescue(e)
	    accident_alert( (is_authentic ? e.to_s : ERR_AUTH) )    
	  end

	  def respond_to_do(format, response, status = 200)
            key = response.respond_to?('keys') ? response[response.keys.first] : "ok"
	    format.html { response[:url].blank? ? (render :text => key) : (redirect_to response[:url]) }
	    supported_formats(format, response, status)
	  end
	  
	  def supported_formats(format, response, status = 200)
	    format.json { render :json => response, :status => status, :head => :ok}
	    format.xml  { render :xml  => response, :status => status, :head => :ok}
	  end

	  def respond_error_to_do(format, response)
	    respond_to_do(format, response.errors, :unprocessable_entity)
	  end
	  
	  def is_authentic
	    current_user || params[:auth_token] || params[:finfore_token]
	  end
      end
      
    end
  end
end
