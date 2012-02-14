class PriceTicker
  include Mongoid::Document
  
  field :ticker, :type => String
  index :ticker
  
  belongs_to :feed_info  
end
