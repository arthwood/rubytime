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
  GROUP_BY_USER = Proc.new {|i| i.user}
  GROUP_BY_PROJECT = Proc.new {|i| i.project}
  GROUP_BY_ROLE = Proc.new {|i| i.user.role}
      
  def my_box(title, size, width, left, top)
    bounding_box([left, bounds.height - top], :width => width) do
      text title, :size => size
      yield
    end
  end
  
  def to_pdf(invoice)
    activities = invoice.activities

    text invoice.name, :size => 16
    
    fill_color '000000'
    
    mb = 20
    
    project_top = 30
    render_items(activities, GROUP_BY_PROJECT) do |project, project_activities|
      my_box("Project: #{project.name}", 12, 400, 0, project_top) do
        role_top = 20
        render_items(project_activities, GROUP_BY_ROLE) do |role, role_activities|
          my_box("Role: #{role.name} #{hourly_rate(project, role, role_activities)}", 11, 370, 20, role_top) do
            user_top = 20
            render_items(role_activities, GROUP_BY_USER) do |user, user_activities|
              user_box(user_activities, user, user_top)
              user_top = bounds.height + mb
            end
          end
          role_top = bounds.height + mb
        end
      end
      project_top = bounds.height + mb
    end
    
    move_down 20
    
    text "Total: #{Activity.total_price(activities)}", :size => 14
    
    render
  end
  
  def hourly_rate(project, role, activities)
    hrs = project.hourly_rates.between_days(activities.first.invoiced_at, activities.last.invoiced_at, role)
    
    v = (hrs.size == 1) \
      ? format_currency_hr(hrs.first) \
      : hrs.map {|i| format_currency_hr(i)}.join(', ')
    
    "(Hourly rate: #{v})"
  end
  
  def render_items(items, grouping, &block)
    items.group_by(&grouping).each_pair(&block)
  end
  
  def user_box(items, i, top)
    my_box(i.name, 10, 340, 20, top) do
      data = items.map(&ACTIVITY_DATA_ROW_MAPPING)
      minutes = items.inject(0, &ACTIVITY_TIME_SPENT_CALC_BLOCK)
      data << ['Total:', format_time_spent(minutes), "value: #{Activity.total_price(items)}"]
      table data, TABLE_OPTIONS
    end
  end
end
