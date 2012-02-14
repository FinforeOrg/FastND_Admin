class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Finforenet::Models::Authenticable
  include Finforenet::Models::SharedQuery
  include Finforenet::Models::Jsonable
  
  field :email_home,            :type => String 
  field :email_work,            :type => String
  field :login,                 :type => String
  field :full_name,             :type => String
  field :is_email_home_primary, :type => Boolean, :default => false
  field :is_online,             :type => Boolean, :default => false
  field :is_public,             :type => Boolean, :default => false
  #field :remember_columns,      :type => String
  #field :remember_companies,    :type => String

  index :email_home
  index :email_work
  index :login
  index :full_name
  
  # User's authorization is using authlogic
  # Change this to your preferred login field
  
  acts_as_authentic do |auth|  
    auth.email_field = :email_work
    auth.ignore_blank_passwords = true if auth.email_field.blank?
    auth.validate_password_field = false if auth.email_field.blank?
    auth.validate_email_field = false if auth.email_field.blank?
    auth.validate_login_field = false if auth.email_field.blank?
    #auth.login_field = 'username'
    #auth.merge_validates_uniqueness_of_login_field_options :scope => '_id', :case_sensitive => true
  end
  
  #Association
  embeds_many :access_tokens,     :cascade_callbacks => true
  embeds_many :feed_accounts,     :cascade_callbacks => true, :order => [[ :position, :asc ]]
  embeds_many :user_company_tabs, :cascade_callbacks => true, :order => [[ :position, :asc ]]
  has_and_belongs_to_many :profiles
  
  accepts_nested_attributes_for :access_tokens, :feed_accounts, :user_company_tabs
  
  #has_many :noticeboard_users
  #has_many :noticeboard_comments
  #has_many :noticeboard_posts
  #has_many :noticeboard_role_users
  #has_many :user_company_tabs, :dependent => :destroy
  
  #validates_uniqueness_of :email_work, :message => "is already taken.", :if => :has_email?
  #validates_presence_of :profession, :on=>:update, :message => "is required", :if => :has_email?
  #validates_presence_of :geographic, :on=>:update, :message => "is required", :if => :has_email?
  #validates_presence_of :industry, :on=>:update, :message => "is required", :if => :has_email?
  validates_format_of :email_work, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "is invalid", :if => :has_email?

  def as_json(options={})
    
    
    if options[:include].blank?
      options = attr_jsonable
    end
    
    super(options)
  end
  
  def attr_jsonable
    {:include => {:profiles => {:only => [:_id,:title],:include  => profile_category_opts},
                                :feed_accounts => user_feeds_opts,
                                :user_company_tabs => feed_info_competitor
                 },
     :except  => user_exceptions}
  end
  
  def create_column(account)
	account = FeedAccount.new(account) if account.class.equal?(Hash)
	account = updated_position(account) unless account.category.match(/portfolio/i)
    self.feed_accounts << account
  end
  
  def create_tab(tab)
	tab = UserCompanyTab.new(tab) if tab.class.equal?(Hash)
	tab = updated_position(tab)
    self.user_company_tabs << tab
  end
  
  def is_exist(work_email)
    is_exist = User.where(:email_work => work_email).count
    self.errors.add(:email_work, "is already taken.") if is_exist > 0
  end
    
  def create_autopopulate
    ['rss', 'podcast', 'chart'].each do |column|
       options = send("#{column}_query")
       options = populated_query(options).merge!(profiles_query(self))   
       
       new_column = FeedAccount.new(options) unless column.match(/chart/i)
       feed_infos = FeedInfo.search_populates(options) 
       feed_infos = FeedInfo.with_populated_prices if column == 'chart' && @feed_infos.size < 1
	    
       feed_infos.each do |feed_info|
	 new_column = FeedAccount.new(options) if column == 'chart'
	 new_column.user_feeds << UserFeed.new({:feed_info_id => feed_info.id, :title => feed_info.title, :category_type => column})
       end
       
       self.feed_accounts << new_column
       UserMailer.missing_suggestions(self.category).deliver if feed_infos.size < 1
     end
     
     self.save
	
     #create populate for company tabs
     options = all_companies_conditions
     profile_ids = @user.profiles.select{|profile| profile.id if !profile.profile_category.title.match(/professi/i) }
     options.merge!({:profile_ids => {"$in" => profile_ids}}) if !profile_ids.size > 0
     tab_infos = FeedInfo.search_populates(@conditions,true)
	
     tab_infos.each do |company_tab|
        self.user_company_tabs << UserCompanyTab.new({:follower => 100, :is_aggregate => false, :feed_info_id => company_tab.id})
     end
     
     self.save
  end
  
  def has_columns?
    (self.feed_accounts.count > 0)
  end

  def self.find_by_id(val)
    self.where(:_id => val).first
  end
  
  def self.by_uid(access_uid)
    self.includes(:access_tokens).where("access_tokens.uid" => access_uid).first
  end
  
  def self.auth_by_security(auth_token, auth_session)
    user = self.where({:single_access_token => auth_token, :perishable_token => auth_session}).first
    user = self.where({:single_access_token => auth_token, :is_public => true}).first if user.blank?
    return user
  end
  
  def self.auth_by_persistence(auth_token, auth_persistence)
    self.where({:single_access_token => auth_token, :persistence_token => auth_persistence}).first
  end
  
  def self.find_public_profile(pids)
    _users = self.where(:is_public => true)
    _return = nil
    _garbage = []
    _users.each do |_user|
      _remain = pids - _user.profiles.map{|profile| profile.id.to_s}
      if _remain.size < 1
        _return = _user
        break
      elsif _remain.size < _user.profiles.count 
        if _garbage.size < 1
          _garbage.push({:user => _user,:remain_size => _remain.size}) 
        else
          last_data = _garbage[0]
          if last_data[:remain_size].to_i > _remain.size
            _garbage.shift
            _garbage.push({:user => _user,:remain_size => _remain.size})
          end  
        end
      end
    end  
    _return = _garbage.shift[:user] if _return.blank? && _garbage.size > 0 
    return _return
  end

  def has_email?
    !self.email_work.blank? && self.access_tokens.size < 1
  end

  def not_social_login?
    !(self.access_tokens.count < 1)
  end
  
  def focuses_by_category
    categories = ProfileCategory.all
    focuses = categories.map{|c| [c.title, self.profiles.find_all_by_profile_category_id(c.id).map(&:title).join(',')]}
    return focuses
  end
  
  def self.search_by(on_page=1,conditions={}, _includes=[])
    Kaminari.paginate_array(self.includes(_includes).where(conditions).asc(:full_name)).page(on_page).per(25)
  end
  
  def self.contains_feed_info(feed_info_id,on_page)
    user_ids = []
    self.all.each do |user|
      user.feed_accounts.each do |feed_account|
        if feed_account.user_feeds.where(:feed_info_id => feed_info_id)
          user_ids.push(user.id) unless user_ids.include?(user.id)
        end
      end
    end
    return Kaminari.paginate_array(self.where(:_id.in => user_ids)).page(on_page).per(25)
  end
  
end
