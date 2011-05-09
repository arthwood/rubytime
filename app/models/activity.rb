require 'activity_report'
require 'csv'

class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :invoice
  belongs_to :currency
  
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
  HIDDEN_JSON_FIELDS = [:created_at, :updated_at]
  
  def as_json(options = {})
    super(
      :include => {
        :project => {}, 
        :user => {:except => User::HIDDEN_JSON_FIELDS},
        :invoice => {:except => User::HIDDEN_JSON_FIELDS}
      }, 
      :except => HIDDEN_JSON_FIELDS, :methods => :time_spent
    )
  end
  
  def time_spent
    @time_spent || Rubytime::Util.format_time_spent(minutes)
  end
  
  def time_spent=(v)
    @time_spent = v
  end
  
  # filter example:
  # {:project_id => 2, :client_id => 3, :user_id => 3, :from => '06-04-2010', :to => '21-04-2010', :invoice_filter => 'all'}}
  def self.search(filter)
    project_id = filter.project_id
    user_id = filter.user_id
    client_id = filter.client_id
    invoice_filter = filter.invoice_filter
    conditions = {}
    conditions[:project_id] = project_id if project_id.present?
    conditions[:user_id] = user_id if user_id.present?
    conditions['projects.client_id'] = client_id if client_id.present?
    scope = invoice_filter.present? ? invoice_filter.to_sym : :all
    from, to = filter.from, filter.to
    from = from.present? ? Date.parse(from) : Date.parse
    to = to.present? ? Date.parse(to) : Date.current
    
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
  
  def self.search_missed(filter)
    user_id = filter.user_id
    conditions = {}
    conditions[:user_id] = user_id if user_id.present?
    from, to = filter.from, filter.to
    date_range = (from.present? && to.present?) \
      ? Date.parse(from)..Date.parse(to) \
      : Date.current.beginning_of_month..Date.current.end_of_month
    conditions[:date] = date_range
    joins = %q{
      LEFT OUTER JOIN users ON (users.id = user_id)
    }
    
    @days = date_range.to_a.reject {|i| i.saturday? || i.sunday?}
    @activities = all(:conditions => conditions, :joins => joins, :order => 'date DESC')
    @users = user_id.present? ? [User.find(user_id)] : User.employees.all
    @user_activities = @activities.group_by(&GROUP_BY_USER_BLOCK)
    
    {}.tap do |result|
      @users.each do |i|
        value = @days - (@user_activities[i] || []).map(&:date) - i.free_days.map(&:date)
        result[i] = value unless value.empty?
      end
    end
  end
  
  def to_csv_row
    [date, project.client.name, project.name, user.name, Rubytime::Util.format_time_spent_decimal(minutes), comments, 
      hourly_rate && Rubytime::Util.format_currency(hourly_rate.currency, total_value)
    ]
  end
  
  def total_value
    hourly_rate.value.to_f * (minutes / 60.0)
  end
  
  def hourly_rate
    project.hourly_rates.with_role(user.role).at_day(date).first
  end
  
  def self.total_value(activities)
    activities.select {|i| 
      i.hourly_rate.present?
    }.group_by {|i| 
      i.hourly_rate.currency
    }.map do |k, v|
      Rubytime::Util.format_currency(k, v.sum(&:total_value))
    end
  end
  
  def self.total_time(activities)
    activities.sum(&:minutes)
  end
  
  def self.to_csv(activities)
    CSV.generate do |csv|
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
