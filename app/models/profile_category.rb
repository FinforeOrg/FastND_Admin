class ProfileCategory
  include Mongoid::Document
  
  field :title, :type => String
  
  has_many :profiles
  #nested_attributes_for :profiles
  
  def as_json(options={})
    
    if options[:include].blank?
      options = {:include => {:profiles =>{:only => [:_id,:title]}},
                 :only    => [:_id,:title]}
    end
    
    super(options)
  end
end
