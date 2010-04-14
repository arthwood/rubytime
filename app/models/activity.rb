class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  validates_presence_of :comments, :date, :project_id, :user_id, :minutes
  validates_format_of :time_spent, :with => /^\d{1,2}:\d{2}$/
  
  def time_spent
    @time_spent || "#{minutes / 60}:#{(minutes % 60).to_s.rjust(2, '0')}"
  end
  
  def time_spent=(v)
    @time_spent = v
  end
  
  # filter {:project_id => 2, :date => {:from => '06-04-2010', :to => '21-04-2010'}, :include => 'all', :user_id => 3}}
  def self.search(filter)
    conditions = {:project_id => filter[:project_id], :user_id => filter[:user_id]}
    date = filter[:date]
    from, to = date[:from], date[:to]
    conditions[:date] = Range.new(from, to) unless from.blank? && to.blank?
    all(:conditions => conditions)
  end
  
  protected
  
  def after_validation
    arr = @time_spent.split(':')
    self.minutes = 60 * arr.first.to_i + arr.last.to_i
  end
end
