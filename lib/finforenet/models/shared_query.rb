module Finforenet
  module Models 
    module SharedQuery
      extend ActiveSupport::Concern
      
      REGEX_MULTIMEDIA = Regexp.new('podcast|audio|media|vodcast|video|mp3|youtube',Regexp::IGNORECASE)
      REGEX_HTTP = Regexp.new('http|feed|https',Regexp::IGNORECASE)
      REGEX_COMPANY = Regexp.new('Company|Index|Currency',Regexp::IGNORECASE)
      
      included do
      end

      module InstanceMethods
        def updated_position(account)
          #	feed_accounts = self.equal?(User) ? self.feed_accounts : account.user.feed_accounts
          begin 
            feed_accounts = self.feed_accounts
          rescue
            feed_accounts = account.user.feed_accounts
          end
          last_position = feed_accounts.where({:position.ne => nil}).desc(:position).first
          account.position = 0
          account.position = last_position.position + 1 unless last_position.blank?
          return account
        end
        
        def updated_tab_position(tab)
          tabs = self.equal?(User) ? self.user_company_tabs : tab.user.user_company_tabs
          last_position = tabs.where({:position.ne => nil}).desc(:position).first
          tab.position = 0
          tab.position = last_position.position + 1 unless last_position.blank?
          return tab
        end
        
        def rss_query(options = {})
          options["$and"] = [{:address=> REGEX_HTTP}, {:address=>{"$not"=> REGEX_MULTIMEDIA}}]
          options[:category] = Regexp.new('rss',Regexp::IGNORECASE)
          return options
        end
        
        def company_query(options={})
          single_ticker = {"$and" => [{:address => /^\W/i}, {:address => {"$not" => /\s+/}} ] }
          options.merge!({"$or" => [{:category => REGEX_COMPANY}, single_ticker ]})
          options.merge!({:address=> {"$not" => REGEX_HTTP}, :category => {"$not" => /chart/i} })
          return options
        end
        
        def twitter_query(options = {})
          options.merge!({:category => /twitter/i, :address => {"$not" => REGEX_HTTP}})
          return options
        end
        
        def all_companies_query(options={})
          return company_query(options)
        end
        
        def populated_query(options = {})
          options[:is_populate] = true
          return options
        end
        
        def profiles_query(user, options = {})
          profile_ids = user.profiles.map(&:id)
          options[:profile_ids] = {"$in" => profile_ids} unless profile_ids.size < 1
          return options
        end
        
        def podcast_query(options={})
          options.merge!({:category => /podcast/i, "$and" => [{:address => REGEX_HTTP}, {:address => {"$not" => /youtube/i}}]})
          return options
        end
        
        def chart_query(options={})
          options.merge!({:category => /chart|price/i, :title => /\w|\W/i})
          #@conditions += " AND price_tickers.feed_info_id = feed_infos.id"
        end    

        def all_query(options={})
          options
        end
        
        def broadcast_query(options={})
          options.merge!({:category => /broadcast/i, "$and" => [{:address => REGEX_HTTP}, {:address => /youtube/i}]})
        end
        
      end
      
      module ClassMethods
        include InstanceMethods
      end
      
    end
  end
end
