class Invoice < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :client
  belongs_to :user
  
  has_many :activities, :dependent => :nullify, :include => [:project, :user]
  
  default_scope :order => :name
  
  def to_csv
    Activity.to_csv(activities)
  end
  
  def to_pdf
    Activity.to_pdf(activities, name, false)
  end
end
