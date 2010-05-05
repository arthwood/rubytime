class HourlyRate < ActiveRecord::Base
  belongs_to :project
  belongs_to :role
  belongs_to :currency
  
  named_scope :with_role, lambda {|i| {:conditions => {:role_id => i.id}}}
  
  def self.current(role)
    at_day(Date.current, role)
  end
  
  def self.at_day(day, role)
    with_role(role).first(:conditions => "date <= '#{day}'", :order => 'date DESC')
  end
  
  def self.between_days(start_day, end_day, role)
    with_role(role).all(:conditions => "date <= '#{start_day}' AND date <= '#{end_day}'", :order => 'date DESC')
  end
end
