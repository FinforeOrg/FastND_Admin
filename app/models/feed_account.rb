class FeedAccount
  include Mongoid::Document
  include Finforenet::Models::SharedQuery
  include Finforenet::Models::Jsonable
  
  #Fields
  field :name,        :type => String
  field :category,    :type => String
  field :window_type, :type => String, :default => "tab"
  field :position,    :type => Integer
  index :category
  
  #Associations
  embedded_in :user
  embeds_one  :feed_token
  embeds_one  :keyword_column
  embeds_many :user_feeds, :cascade_callbacks => true
  
  accepts_nested_attributes_for :keyword_column, :user_feeds, :feed_token
  
  before_create :check_position
  
  validates :category, :presence => true
  validates :name, :presence => true

  def as_json(options)
    if options[:include].blank?
      options = user_feeds_opts
	end                        
	super(options)
  end
  
  def check_position
    self.position = updated_position(self).position if self.position.blank? && !self.category.match(/portfolio/i)	
  end
  
  def create_keyword(options)
    self.keyword_column = KeywordColumn.new(options)
    self.save
    #i = 0
    #until i > keys.size-1
    #  keywords = keys[i..(i+2)].to_sentence({:last_word_connector => ", ", :two_words_connector => ", "})
     # KeywordColumn.create({:keyword=>keywords,:is_aggregate=>false,:follower=>0,:user_id => user_id,:feed_account_id=>account_id})
     # i += 3
    #end

    #keys.each do |key|
    #  create_or_update_feed_info(key,category)
    #end
  end
  
  def create_user_feeds
  end
  
  # Check whether the column is twitter
  def isTwitter?
    self.category =~ /(tweet|twitter|suggested)/i
  end
  
  # Check whether the column is rss
  def isRss?
    self.category =~ /(rss)/i
  end

  # Check whether the column is linkedin
  def isLinkedin?
    self.category =~ /(linkedin|linked-in)/i
  end

  # Check whether the column is podcast
  def isPodcast?
    self.category =~ /(podcast|video|audio)/i
  end

  # Check whether the column is price
  def isChart?
    self.category =~ /(price|chart)/i
  end

  # Check whether the column is company
  def isCompany?
    self.category =~ /(company|index|currency)/i
  end

  # Check whether the column is keyword
  def isKeyword?
    self.category =~ /(keyword)/i
  end

  # Check whether the column is followable to any twitter account
  def isFollowable?
    isTwitter? || isCompany?
  end
  
  def hasAggregate?
    isCompany? || isKeyword?
  end

  # Check whether the column is portfolio tab
  def isPortfolio?
    self.category =~ /portfolio/i
  end

  def isOauth?
   isTwitter? || isGoogle? || isFacebook?
  end

  def isFacebook?
    self.category =~ /facebook/i
  end

  def isGoogle?
    self.category =~ /(gmail|google|portfolio)/i
  end

end
