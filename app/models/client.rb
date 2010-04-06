class Client < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :active
  
  has_many :users, :dependent => :destroy
end
