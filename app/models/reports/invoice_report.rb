class InvoiceReport < Prawn::Document
  TABLE_OPTIONS = {
    :headers => ['Date', 'Time', 'Comments'], 
    :font_size => 10, 
    :header_color => '86CFEF', 
    :border_width => 1, 
    :border_style => :grid, 
    :border_color => 'CCCCCC', 
    :row_colors => ['FFFFFF', 'EEEEEE']
  }
  
  ACTIVITY_DATA_ROW_MAPPING = Proc.new {|i| [i.date, i.time_spent, i.comments]}
  ACTIVITY_TIME_SPENT_CALC_BLOCK = Proc.new {|mem, i| mem + i.minutes}
  
  def my_box(w, s_color, f_color, margin = {}, padding = 5, &block)
    margin_left = margin[:left] || 20
    margin_top = margin[:top] || 20
    bounding_box([margin_left, bounds.top - margin_top], :width => w) do
      fill_color '000000'
      bounding_box([padding, bounds.top - padding], :width => w - margin_left, &block)
      stroke_color s_color
      fill_color f_color
      move_down padding
      fill_and_stroke_rounded_rectangle [bounds.top, bounds.left], bounds.width, bounds.height, 10
    end
  end
  
  def to_pdf(invoice)
    activities = invoice.activities
    text invoice.name, :size => 16
    
    by_projects = activities.group {|i| i.project}
    by_projects.each_pair do |project, project_activities|
      my_box(400, 'E6E6E6', 'F6F6F6', {:top => 40, :left => 0}) do
        text "Project: #{project.name}", :size => 12
        by_roles = project_activities.group {|i| i.user.role}
        by_roles.each_pair do |role, role_activities|
          my_box(370, 'ECECEC', 'FCFCFC') do
            hr = project.hourly_rates.current(role)
            txt = hr.nil? ? '(Hourly rate not defined!)' : "(Hourly rate: #{format_currency_hr(hr)})"
            text "Role: #{role.name} #{txt}", :size => 11
            
            by_users = role_activities.group {|i| i.user}
            by_users.each_pair do |user, user_activities|
              my_box(340, 'EEEEEE', 'FFFFFF') do
                text user.name, :size => 10
                data = user_activities.map(&ACTIVITY_DATA_ROW_MAPPING)
                minutes = user_activities.inject(0, &ACTIVITY_TIME_SPENT_CALC_BLOCK)
                value = format_currency(hr.currency, hr.value * minutes / 60.0)
                data << ['Total:', format_time_spent(minutes), "value: #{value}"]
                table data, TABLE_OPTIONS
              end
            end
          end
        end
      end
    end
    
    render
  end
end
