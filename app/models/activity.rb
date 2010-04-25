class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  validates_presence_of :comments, :date, :project_id, :user_id, :minutes
  validates_format_of :time_spent, :with => /^\d{1,2}:\d{2}$/
  validate :time_spent_values
  
  named_scope :for_day, lambda {|date| {:conditions => {:date => date}}}
  
  def as_json(options = {})
    super(:include => [:project, :user], :methods => :time_spent)
  end
  
  def time_spent
    @time_spent || "#{minutes.to_i / 60}:#{(minutes.to_i % 60).to_s.rjust(2, '0')}"
  end
  
  def time_spent=(v)
    @time_spent = v
  end
  
  # filter {:project_id => 2, :date => {:from => '06-04-2010', :to => '21-04-2010'}, :include => 'all', :user_id => 3}}
  def self.search(filter)
    project_id = filter.project_id
    user_id = filter.user_id
    conditions = {}
    conditions[:project_id] = project_id unless project_id.blank?
    conditions[:user_id] = user_id unless user_id.blank?
    from, to = filter.from, filter.to
    from = from.blank? ? nil : Date.parse(from)
    to = to.blank? ? nil : Date.parse(to)
    
    conditions[:date] = Range.new(from, to) if from || to
    
    all(:conditions => conditions, :include => :project, :order => 'date DESC')
  end
  
  protected
  
  def after_validation
    arr = @time_spent.split(':')
    self.minutes = 60 * arr.first.to_i + arr.last.to_i
  end
  
  def time_spent_values
    hours, minutes = time_spent.split(':')
    errors.add(:time_spent, 'has invalid format') if minutes.to_i > 59
  end
end
