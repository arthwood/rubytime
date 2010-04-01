ADMIN_EMAIL = 'artur.bilski@llp.pl'

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  match = /class=\"([a-zA-Z0-9_\s]*)\"/.match(html_tag)
  
  if $&
    html_tag.gsub($&, %Q{class="#{$1} invalid"})
  else
    match = /^\<\w+/.match(html_tag)
    html_tag.gsub($&, %Q{#{$&} class="invalid"})
  end
end
