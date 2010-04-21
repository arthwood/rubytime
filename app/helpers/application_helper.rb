module ApplicationHelper
  def set_c_and_a
    @c = params[:controller]
    @a = params[:action]
  end
  
  SECTIONS = {
    :manage => [{:c => :users}, {:c => :clients}, {:c => :projects}, {:c => :roles}, {:c => :currencies}, {:c => :settings}],
    :activities => [{:c => :activities}],
    :invoices => [{:c => :invoices}]
  }
  
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
  
  def error_field(form, attr)
    error_message_on(form.object_name, attr, :css_class => :error)
  end
  
  ROW_CLASSES = %w(odd even)
  
  def row_class(i)
    ROW_CLASSES[i % 2]
  end
  
  def admin?
    current_user.admin
  end
  
  def form_header(object)
    create_mode = object.new_record?
    name = object.class.name.downcase
    
    create_mode ? "Add new #{name}" : "Edit #{name} " + content_tag(:span, "(or #{link_to('add new', polymorphic_path(object, :action => :new))})")
  end
  
  def daterange_options(selected = nil)
    now = Date.current
    options_for_select [
      daterange('Today', now, now),
      daterange('Yesterday', now.yesterday, now.yesterday),
      daterange('This Week', now.beginning_of_week, now.end_of_week),
      daterange('Last Week', 1.week.ago.beginning_of_week, 1.week.ago.end_of_week),
      daterange('This Month', now.beginning_of_month, now.end_of_month),
      daterange('Last Month', 1.month.ago.beginning_of_month, 1.month.ago.end_of_month)
    ], selected
  end
  
  def daterange(label, from, to)
    ["#{label} (#{from.strftime('%d/%m/%Y')} - #{to.strftime('%d/%m/%Y')})", 
     "#{from.strftime('%d-%m-%Y')}/#{to.strftime('%d-%m-%Y')}"
    ]
  end
  
  def group(arr, &block)
    result = {}
    
    arr.each do |i|
      key = block.call(i)
      
      if result[key]
        result[key] << i
      else
        result[key] = [i]
      end
    end
    
    result
  end
  
  def time_spent(minutes)
    "#{minutes.to_i / 60}:#{(minutes.to_i % 60).to_s.rjust(2, '0')}"
  end
  
  def activity_field_id(name)
    "#{@prefix}_activity_#{name}"
  end
end
