class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :invoice
  belongs_to :currency
  
  validates_presence_of :comments, :date, :project_id, :user_id
  validates_uniqueness_of :project_id, :scope => [:date, :user_id], :message => 'activity for this project already exists at that day'
  validates_format_of :time_spent, :with => /^\d{1,2}:\d{2}$/
  validate :time_spent_values
  
  named_scope :for_day, lambda {|date| {:conditions => {:date => date}}}
  named_scope :invoiced, :conditions => 'invoice_id IS NOT NULL'
  named_scope :not_invoiced, :conditions => 'invoice_id IS NULL'
  
  default_scope :order => 'DATE DESC'
  
  after_save :check_day_off
  
  def as_json(options = {})
    super(:include => [:project, :user], :methods => :time_spent)
  end
  
  def time_spent
    @time_spent || format_time_spent(minutes)
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
    from = from.blank? ? nil : Date.parse(from)
    to = to.blank? ? nil : Date.parse(to)
    
    conditions[:date] = Range.new(from, to) if from || to
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
  
  def to_csv_row
    [date, project.name, user.name, time_spent, comments, format_currency(currency, price)]
  end
  
  def self.total_price(items)
    by_currency = items.group {|i| i.currency}
    by_currency.map do |k, v|
      format_currency(k, v.inject(0) {|mem, i| mem + i.price.to_f * (i.minutes / 60.0)})
    end.join(' + ')
  end
  
  protected
  
  def after_validation
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
