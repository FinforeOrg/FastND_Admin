# column name and category_type in user_feed are deprecated
# if user create new user_feed for a column, system will create to feed_info
# system will mark :is_user is TRUE if feed_info is created by user, but FALSE for admin.
# For custom feed_info name will go to user_feed's title, the name in feed_info should be blank, only ADMIN that can enter it.

class UserFeed
  include Mongoid::Document
  
  field :title, :type => String
  index :title
  
  embedded_in :feed_account
  belongs_to :feed_info
  attr_accessor :feed_info_attributes
  before_save :check_feed_info

  #accepts_nested_attributes_for :feed_info

  def feed_info_attributes(attr)
    @feed_info_attributes = attr
  end

  def feed_info_attributes
    @feed_info_attributes
  end
  
  def as_json(options={})
    if options.blank?
      options = {:include => [:feed_info], :except => [:feed_info_id]}
    end
    super(options)
  end

  def before_destroy
    self.feed_info.inc(:follower, -1) if self.feed_info
  end
  
  def after_create
    self.feed_info.inc(:follower, 1)
  end
  
  #def feed_info
  #  FeedInfo.find(self.feed_info_id) unless self.feed_info_id.blank?
  #end

  def isSuggestion?
    self.category_type =~ /(tweet|twitter|suggested)/i
  end

  def isRss?
    self.category_type =~ /(rss)/i
  end

  def isPodcast?
    self.category_type =~ /(podcast|video|audio)/i
  end

  def isChart?
    self.category_type =~ /(price|chart)/i
  end

  def isCompany?
    self.category_type =~ /(company|index|currency)/i
  end

  def isKeyword?
    self.category_type =~ /(keyword)/i
  end
  
  def check_feed_info
    if @feed_info_attributes.present?
      if @feed_info_attributes["_id"].present?
        info = FeedInfo.where(:_id => @feed_info_attributes["_id"]).first
        info.update_attributes(@feed_info_attributes) if info
      else
        info = FeedInfo.create(@feed_info_attributes)
        if info
          self.feed_info = info
          #self.save
        end
      end 
    end
  end

end
