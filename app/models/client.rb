class Client < ActiveRecord::Base
  validates_presence_of     :name
  validates_uniqueness_of   :name
  validates_length_of       :name, :maximum => 100
  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i
  validates_inclusion_of    :active, :in => [true, false]
  
  has_many :users, :dependent => :destroy
  has_many :invoices
  has_many :projects
  
  default_scope :order => :name
  
  def collaborators
    projects.map(&:users).flatten.uniq
  end
end
