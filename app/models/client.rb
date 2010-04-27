class Client < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :active, :in => [true, false]
  
  has_many :users, :dependent => :destroy
  
  default_scope :order => :name
end
