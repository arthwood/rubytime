class Role < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :can_manage_financial_data
  
  ROLES = ['developer', 'project manager', 'tester']
end
