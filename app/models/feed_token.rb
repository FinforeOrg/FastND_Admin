class FeedToken
  include Mongoid::Document

  field :token,          :type => String
  field :secret,         :type => String
  field :token_preauth,  :type => String
  field :secret_preauth, :type => String
  field :url_oauth,      :type => String
  field :uid,            :type => String
  
  index :uid
  index :token
  index :secret
  index :token_preauth
  index :secret_preauth

  embedded_in :feed_account

end
