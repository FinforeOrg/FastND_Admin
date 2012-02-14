class AccessToken
  include Mongoid::Document
  
  field :category, :type => String
  field :token,    :type => String
  field :secret,   :type => String
  field :uid,      :type => String
  
  index :category
  index :uid
  
  embedded_in :user
end
