class Profile
  include Mongoid::Document
  
  field :title, :type => String
  field :is_private, :type => Boolean
  
  index :title
  default_scope asc(:title)
  has_and_belongs_to_many :users
  has_and_belongs_to_many :feed_infos
  has_and_belongs_to_many :populate_feed_infos
  belongs_to :profile_category
  
  def self.without(disclude)
    self.all(:include=>:profile_category,
             :conditions=>"profile_categories.title !~* '#{disclude}'")
  end

  def self.public
     self.all(:conditions => "is_private IS NOT TRUE")
  end
  
end
