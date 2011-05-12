class User < ActiveRecord::Base
  include BCrypt
  
  validates_presence_of     :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => /\A\w[\w\.\-_@]+\z/
  validates_format_of       :name, :with => /\A[^[:cntrl:]\\<>\/&]*\z/, :allow_nil => true
  validates_length_of       :name, :maximum => 100
  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i
  validates_inclusion_of    :active, :in => [true, false]
  validates_presence_of     :password_hash
  validates_presence_of     :password_confirmation, :if => :password_hash_changed?
  validates_confirmation_of :password, :if => :password_hash_changed?
  
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
  
  attr_accessor :password_confirmation
  
  attr_protected :login_key, :password_hash
  
  HIDDEN_JSON_FIELDS = [:password_hash, :remember_token, :remember_token_expires_at, :login_key, :created_at, :updated_at]
  
  def password
    if password_hash.nil?
      @password = nil
    else
      @password ||= Password.new(password_hash)
    end 
  end
  
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  def group
    employee? ? 0 : 1
  end
  
  def employee?
    client_id.blank?
  end
  
  def client?
    client_id.present?
  end

  def editor?
    admin? || employee?
  end
  
  def create_login_key
    set_login_key(SecureRandom.hex(16))
  end
  
  def clear_login_key
    set_login_key(nil)
  end
  
  private
  
  def set_login_key(value)
    self.login_key = value
    save
  end
end
