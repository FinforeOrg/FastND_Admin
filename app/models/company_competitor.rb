class CompanyCompetitor
  include Mongoid::Document
  
  field :keyword,           :type => String
  field :competitor_ticker, :type => String
  field :company_keyword,   :type => String
  field :broadcast_keyword, :type => String
  field :finance_keyword,   :type => String
  field :bing_keyword,      :type => String
  field :blog_keyword,      :type => String
  field :company_ticker,    :type => String
  
  belongs_to :feed_info
end
