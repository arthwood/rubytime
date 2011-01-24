class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :active, :in => [true, false]
  
  belongs_to :client
  
  has_many :hourly_rates
  has_many :activities
  has_many :user_mailers, :through => :activities, :uniq => true

  default_scope :order => :name
  
  def as_json(options = {})
    super(:include => :client)
  end
end
