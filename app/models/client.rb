class Client < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :active, :in => [true, false]
  
  has_many :users, :dependent => :destroy
  has_many :invoices
  has_many :projects

  default_scope :order => :name
  
  def collaborators
    projects.map(&:users).flatten.uniq
  end
end
