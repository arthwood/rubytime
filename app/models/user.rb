require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name, :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name, :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  validates_inclusion_of :active, :in => [true, false]
  
  attr_accessible :login, :email, :name, :password, :password_confirmation, :active, :role_id, :client_id
  
  belongs_to :client
  belongs_to :role
  
  has_many :activities
  has_many :projects, :through => :activities
  
  named_scope :employees, :conditions => 'client_id IS NULL'
  
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase)
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def reset_login_key!
    update_attribute(:login_key, Digest::SHA1.hexdigest(Time.now.to_s + crypted_password.to_s + rand(123456789).to_s))
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
end
