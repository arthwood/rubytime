class HourlyRate < ActiveRecord::Base
  belongs_to :project
  belongs_to :role
  belongs_to :currency
  
  named_scope :with_role, lambda {|i| {:conditions => {:role_id => i.id}}}
end
