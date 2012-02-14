module Finforenet
  module Models
	module Jsonable
	  
	  extend ActiveSupport::Concern
	  
	  included do
	  end
	
	  module InstanceMethods

	    def profile_category_opts
		  {:profile_category => {:only => [:id,:title] } }
		end
		
		def feed_info_onlys
		  [:address, :category, :title, :id]
		end
		
		def feed_info_exception
		  [:is_populate, :profile_ids, :id, :is_user]
		end
		
		def feed_info_competitor
		  {:include => {:feed_info => company_competitor}}
		end
		
		def price_ticker_opts
		  {:price_tickers => {:only => [:ticker]}}
		end
		
		def feed_info_prices_opts
		  {:feed_info => {:include => price_ticker_opts, :only => feed_info_onlys } }
		end
		
		def company_competitor
		  {:include => {:company_competitor => { :except=> [:feed_info_id] }}, :only => feed_info_onlys}
		end
		
		def user_feeds_opts
		  {:include => {:feed_token => {:except => []}, :keyword_column => {:except => []}, :user_feeds => {:include => feed_info_prices_opts }  } }
		end
		
		def user_exceptions
		  [:crypted_password,:password_salt,:profile_ids, :updated_at, :created_at, :is_online, :remember_columns, :remember_companies]
		end
		
	  end
	  
	  module ClassMethods
	  end
	end
  end
end
