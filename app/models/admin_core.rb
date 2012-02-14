class AdminCore
  include Mongoid::Document
  include Mongoid::Timestamps
  include Finforenet::Models::Authenticable

  field :login, :type => String
  field :email, :type => String
  field :full_name, :type => String
  field :last_login_ip, :type => String
  field :last_login_at, :type => Time
  
  acts_as_authentic do |auth|
    validates_uniqueness_of :login, :message => "is already taken."
  end
  
  #belongs_to :role
  #belongs_to :team

  def self.find_by_id(val)
    self.where(:_id => val).first
  end

end
