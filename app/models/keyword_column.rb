class KeywordColumn
  include Mongoid::Document
  
  field :keyword,      :type => String
  field :is_aggregate, :type => Boolean
  field :follower,     :type => Integer
  
  index :keyword

  embedded_in :feed_account
  
end
