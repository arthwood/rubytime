class HourlyRate < ActiveRecord::Base
  belongs_to :project
  belongs_to :role
  belongs_to :currency
  
  default_scope :order => 'date DESC'
  
  named_scope :with_role, lambda {|i| {:conditions => {:role_id => i.id}}}
  
  def successor
    project.hourly_rates.with_role(role).first(:conditions => "date > '#{date}'", :order => 'date ASC')
  end
  
  def self.current(role)
    with_role(role).at_day(Date.current)
  end
  
  def self.at_day(day)
    first(:conditions => "date <= '#{day}'")
  end
  
  def self.between_days(range)
    all(:conditions => {:date => range})
  end
end
