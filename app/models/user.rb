class User < ActiveRecord::Base
  include BCrypt
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => /\A\w[\w\.\-_@]+\z/

  validates_format_of       :name, :with => /\A[^[:cntrl:]\\<>\/&]*\z/, :allow_nil => true
  validates_length_of       :name, :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i
  
  validates_inclusion_of :active, :in => [true, false]
  
  belongs_to :client
  belongs_to :role
  
  has_many :activities, :include => :project
  has_many :projects, :through => :activities, :uniq => true
  has_many :invoices
  has_many :free_days
  
  default_scope :order => :name
  
  scope :employees, where('client_id IS NULL')
  scope :clients, where('client_id IS NOT NULL')
  scope :not_admins, where('admin = 0')
  scope :admins, where('admin = 1')
  
  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  def group
    employee? ? 0 : 1
  end
  
  def employee?
    client_id.nil?
  end
  
  def client?
    !client_id.nil?
  end

  def editor?
    admin? || employee?
  end
end
