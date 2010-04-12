class Activity < ActiveRecord::Base
  validates_presence_of :comments, :date, :project_id, :user_id, :minutes
  
  TIME_SPENT_RE = /^\d{1,2}:\d{2}$/
  
  def time_spent
    @time_spent || "#{minutes / 60}:#{(minutes % 60).to_s.rjust(2, '0')}"
  end
  
  def time_spent=(v)
    @time_spent = v
    
    if v =~ TIME_SPENT_RE
      p 1
      arr = v.split(':')
      self.minutes = 60 * arr.first.to_i + arr.last.to_i  
    else
      p 2
      errors.add(:minutes, 'has invalid format')
      p errors.full_messages
    end
  end
end
