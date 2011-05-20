class HourlyRate < ActiveRecord::Base
  validates_presence_of :project_id, :role_id, :currency_id
  
  belongs_to :project
  belongs_to :role
  belongs_to :currency
  
  default_scope :order => 'date DESC'
  
  scope :with_role, lambda {|i| {:conditions => {:role_id => i.id}}}
  scope :at_day, lambda {|i| {:conditions => "date <= '#{i}'", :order => {:date => :desc}, :limit => 1}}
end
