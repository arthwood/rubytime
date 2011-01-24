require 'activity_report'
require 'fastercsv'

class Activity < ActiveRecord::Base
  belongs_to :user_mailer
  belongs_to :project
  belongs_to :invoice
  
  validates_presence_of :comments, :date, :project_id, :user_id
  validates_uniqueness_of :project_id, :scope => [:date, :user_id], :message => 'activity for this project already exists at that day'
  validates_format_of :time_spent, :with => /^\d{1,2}:\d{2}$/
  validate :time_spent_values
  
  scope :for_projects, lambda {|p| {:conditions => {:project_id => p}}}
  scope :for_day, lambda {|date| {:conditions => {:date => date}}}
  scope :invoiced, where('invoice_id IS NOT NULL')
  scope :not_invoiced, where('invoice_id IS NULL')
  
  default_scope :order => 'DATE DESC'
  
  after_save :check_day_off
  after_validation :set_minutes
  
  GROUP_BY_CLIENT_BLOCK = Proc.new {|i| i.project.client}
  GROUP_BY_PROJECT_BLOCK = Proc.new {|i| i.project}
  GROUP_BY_ROLE_BLOCK = Proc.new {|i| i.user.role}
  GROUP_BY_USER_BLOCK = Proc.new {|i| i.user}
  GROUP_BY_DATE_BLOCK = Proc.new {|i| i.date}
  GROUP_BY_CURRENCY_BLOCK = Proc.new {|i| i.hourly_rate.currency}
  TIME_SPENT_BLOCK = Proc.new {|mem, i| mem + i.minutes}
  
  def as_json(options = {})
    super(:include => [:project, :user], :methods => :time_spent)
  end
  
  def time_spent
    @time_spent || Rubytime::Util.format_time_spent(minutes)
  end
  
  def time_spent=(v)
    @time_spent = v
  end
  
  # filter example:
  # {:project_id => 2, :date => {:from => '06-04-2010', :to => '21-04-2010'}, :invoice_filter => 'all', :user_id => 3}}
  def self.search(filter)
    project_id = filter.project_id
    user_id = filter.user_id
    client_id = filter.client_id
    invoice_filter = filter.invoice_filter
    conditions = {}
    conditions[:project_id] = project_id unless project_id.blank?
    conditions[:user_id] = user_id unless user_id.blank?
    conditions['projects.client_id'] = client_id unless client_id.blank?
    scope = (invoice_filter.blank? && :all) || invoice_filter.to_sym
    from, to = filter.from, filter.to
    from = from.blank? ? Date.parse : Date.parse(from)
    to = to.blank? ? Date.current : Date.parse(to)
    
    conditions[:date] = Range.new(from, to)
    joins = %q{
      LEFT OUTER JOIN users ON (users.id = user_id)
      LEFT OUTER JOIN projects ON (projects.id = project_id)
      LEFT OUTER JOIN clients ON (clients.id = projects.client_id)
    }
    
    options = {:conditions => conditions, :joins => joins, :order => 'date DESC'}
    
    case scope
      when :all
        all(options)
      when :invoiced
        invoiced.all(options)
      when :not_invoiced
        not_invoiced.all(options)
      else
        []
    end
  end
  
  WEEKENDS = [0, 6]
  
  def self.search_missed(filter)
    user_id = filter.user_id
    conditions = {}
    conditions[:user_id] = user_id unless user_id.blank?
    from, to = filter.from, filter.to
    date_range = (from.blank? || to.blank?) \
      ? Date.current.beginning_of_month..Date.current.end_of_month \
      : Date.parse(from)..Date.parse(to)
    conditions[:date] = date_range
    joins = %q{
      LEFT OUTER JOIN users ON (users.id = user_id)
    }
    
    @days = date_range.to_a.reject {|i| WEEKENDS.include?(i.wday)}
    @activities = all(:conditions => conditions, :joins => joins, :order => 'date DESC')
    
    @users = user_id.blank? ? User.employees.all : [User.find(user_id)]
    @user_activities = @activities.group_by(&GROUP_BY_USER_BLOCK)
    @users.inject({}) do |mem, i|
      mem[i] = @days - (@user_activities[i] || []).map(&:date); mem
    end.reject {|k, v| v.empty?}
  end
  
  def to_csv_row
    [date, project.client.name, project.name, user.name, Rubytime::Util.format_time_spent_decimal(minutes), comments, 
      hourly_rate && format_currency(hourly_rate.currency, total_value)
    ]
  end
  
  def total_value
    hourly_rate.value.to_f * (minutes / 60.0)
  end
  
  def self.total_value(activities)
    by_currency = activities.reject {|i| i.hourly_rate.nil?}.group_by(&GROUP_BY_CURRENCY_BLOCK)
    by_currency.map do |k, v|
      format_currency(k, v.inject(0) {|mem, i| mem + i.total_value})
    end.join(' + ')
  end
  
  def hourly_rate
    project.hourly_rates.with_role(user.role).at_day(invoiced_at || Date.current)
  end
  
  def self.total_time(activities)
    activities.inject(0, &TIME_SPENT_BLOCK)
  end
  
  def self.to_csv(activities)
    FasterCSV.generate do |csv|
      csv << ['Date', 'Client', 'Project', 'Person', 'Time Spent', 'Comments', 'Price']
      activities.sort_by{|i| i.project.client.name}.each do |i|
        csv << i.to_csv_row
      end
      csv << [nil, nil, nil, nil, 'Total:', "#{total_value(activities)}"]
    end
  end
  
  def self.to_pdf(activities, title, hide_users)
    ActivityReport.new.to_pdf(activities, title, hide_users)
  end
  
  protected
  
  def set_minutes
    if @time_spent
      arr = @time_spent.split(':')
      self.minutes = 60 * arr.first.to_i + arr.last.to_i
    end
  end
  
  def time_spent_values
    hours, minutes = time_spent.split(':')
    errors.add(:time_spent, 'has invalid format') if minutes.to_i > 59
  end
  
  def check_day_off
    (day_off = FreeDay.first(:conditions => {:user_id => user_id, :date => date})) && day_off.destroy
  end
end
