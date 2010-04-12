class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :active, :in => [true, false]
  
  belongs_to :client
end
