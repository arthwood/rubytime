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
end
