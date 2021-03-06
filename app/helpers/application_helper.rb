module ApplicationHelper
  def set_c_and_a
    @c = params[:controller]
    @a = params[:action]
  end
  
  def js_env
    javascript_tag do
      %Q{
        var env = {
          user: {editor: #{logged_in? && editor?}},
          token: '#{form_authenticity_token}'
        };
      }
    end
  end
  
  SECTIONS = {
    :manage => [{:c => :users}, {:c => :clients}, {:c => :projects}, {:c => :roles}, {:c => :currencies}, {:c => :settings}],
    :activities => [{:c => :activities}],
    :invoices => [{:c => :invoices}]
  }
  ROW_CLASSES = %w(even odd)
  
  def section
    c = @c.to_sym
    SECTIONS.detect {|i, j| j.any? {|k| k[:c] == c}}.first
  end
  
  def menu_link(label, url)
    options = {}
    options[:class] = :selected if section.to_s == label
    
    link_to label, url, options
  end
  
  def submenu_link(label, url)
    options = {}
    options[:class] = :selected if url_for(params.merge(:only_path => false)) == url
    
    link_to label, url, options
  end
  
  def verbalize(yes)
    yes ? 'yes' : 'no'
  end
  
  def error_field(record, attr)
    errors = record.errors[attr]
    content_tag(:div, errors.first, :class => :error) unless errors.empty?
  end
  
  def row_class(i)
    ROW_CLASSES[i % 2]
  end
  
  def admin?
    current_user.admin?
  end

  def editor?
    current_user.editor?
  end

  def client?
    current_user.client?
  end

  def admin_or_client?
    admin? || client?
  end

  def form_header(object)
    create_mode = object.new_record?
    name = object.class.name.downcase
    
    if create_mode 
      "Add new #{name}"
    else
      link = link_to('add new', new_polymorphic_path(object))
      span = content_tag(:span, "(or #{link})".html_safe)
      "Edit #{name} #{span}".html_safe
    end
  end
  
  def daterange_options
    now = Date.current
    options_for_select [
      daterange('Today', now, now),
      daterange('Yesterday', now.yesterday, now.yesterday),
      daterange('This Week', now.beginning_of_week, now.end_of_week),
      daterange('Last Week', 1.week.ago.beginning_of_week, 1.week.ago.end_of_week),
      daterange('This Month', now.beginning_of_month, now.end_of_month),
      daterange('Last Month', 1.month.ago.beginning_of_month, 1.month.ago.end_of_month)
    ]
  end
  
  def daterange(label, from, to)
    [
      "#{label} (#{Rubytime::Util.format_date(from, '/')} - #{Rubytime::Util.format_date(to, '/')})", 
      "#{Rubytime::Util.format_date(from)}/#{Rubytime::Util.format_date(to)}"
    ]
  end
  
  def activity_field_id(name)
    "#{@prefix}_activity_#{name}"
  end
  
  def day_off_tag
    link_to image_tag('day_off.png', :title => 'Day off'), day_off_activities_path
  end
  
  def revert_day_off_tag
    link_to image_tag('revert_day_off.png', :title => 'Revert day off'), revert_day_off_activities_path, :class => :revert
  end
end
