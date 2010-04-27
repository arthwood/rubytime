class Invoice < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  
  default_scope :order => :name
end
