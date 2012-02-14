class UserCompanyTab
  include Mongoid::Document
  include Finforenet::Models::SharedQuery
  include Finforenet::Models::Jsonable
  
  field :follower,     :type => Integer
  field :is_aggregate, :type => Boolean
  field :position,     :type => Integer
  
  embedded_in :user
  belongs_to :feed_info
  
  before_create :check_position
  
  def as_json(options={})
    if options[:include].blank?
      options = {:include => {:feed_info=> { :include => {:company_competitor => { :except=> [:feed_info_id] }},
	                                         :except => [:profile]
	                                       },                           
                             } }
    end
    super(options)
  end
  
  def check_position
	  self.position = updated_tab_position(self).position if self.position.blank?
  end
  
end
