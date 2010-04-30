class Invoice < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :client
  belongs_to :user
  
  has_many :activities, :dependent => :nullify
  
  default_scope :order => :name
end
