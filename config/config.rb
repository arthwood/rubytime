ADMIN_EMAIL = 'artur.bilski@llp.pl'

=begin

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag
  %(<span class="field-with-errors">#{html_tag}</span>)
end

=end

