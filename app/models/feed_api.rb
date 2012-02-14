class FeedApi
  include Mongoid::Document
  
  #Fields
  field :api,      :type => String
  field :secret,   :type => String
  field :category, :type => String
  
  index :category
  
  cache
  
  def self.auth_by(category)
	category = category.gsub(/gmail|portfolio/i,"google")
	self.where(:category => /#{category}/i).first
  end

  def isFacebook?
    self.category =~ /(facebook)/i
  end

end
