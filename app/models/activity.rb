class Activity < ActiveRecord::Base
  validates_presence_of :comments, :date, :project_id, :user_id, :minutes
  validates_numericality_of :minutes
  
  def time_spent
    minutes && "#{minutes / 60}:#{minutes % 60}"
  end
  
  def time_spent=(v)
    arr = v.split(':')
    
    self.minutes = 60 * arr.first.to_i + arr.last.to_i
  end
end
