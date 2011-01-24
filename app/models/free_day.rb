class FreeDay < ActiveRecord::Base
  validates_presence_of :user_id, :date
  
  belongs_to :user_mailer
end
