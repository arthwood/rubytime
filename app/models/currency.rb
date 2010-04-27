class Currency < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :plural
  validates_uniqueness_of :plural
  validates_presence_of :symbol
  validates_uniqueness_of :symbol
  
  validates_inclusion_of :prefix, :in => [true, false]
  
  default_scope :order => :name
end
