class ActivityReport < Prawn::Document
  TABLE_OPTIONS = {
    :headers => ['Date', 'Time', 'Comments', 'Invoiced', 'Hourly rate'], 
    :font_size => 10, 
    :header_color => '86CFEF', 
    :border_width => 1, 
    :border_style => :grid, 
    :border_color => 'CCCCCC', 
    :row_colors => ['FFFFFF', 'EEEEEE'],
    :column_widths => {0 => 70, 1 => 40, 2 => 170, 3 => 70, 4 => 50}
  }
  
  ACTIVITY_DATA_ROW_MAPPING = Proc.new do |i| 
    [i.date, format_time_spent_decimal(i.minutes), i.comments, i.invoiced_at, format_currency_hr(i.hourly_rate)]
  end
  
  def my_box(title, size, width, left, top)
    bounding_box([left, bounds.height - top], :width => width) do
      text title, :size => size
      yield
    end
  end
  
  def to_pdf(activities, title)
    text title, :size => 16
    
    fill_color '000000'
    
    mb = 20
    
    client_top = 30
    
    render_items(activities, Activity::GROUP_BY_CLIENT_BLOCK) do |client, client_activities|
      my_box("Client: #{client.name}", 12, 420, 0, client_top) do
        project_top = 20
        render_items(client_activities, Activity::GROUP_BY_PROJECT_BLOCK) do |project, project_activities|
          my_box("Project: #{project.name}", 12, 400, 20, project_top) do
            role_top = 20
            render_items(project_activities, Activity::GROUP_BY_ROLE_BLOCK) do |role, role_activities|
              my_box("Role: #{role.name}", 11, 380, 20, role_top) do
                user_top = 20
                render_items(role_activities, Activity::GROUP_BY_USER_BLOCK) do |user, user_activities|
                  user_box(user_activities, user, user_top)
                  user_top = bounds.height + mb
                end
              end
              role_top = bounds.height + mb
            end
          end
          project_top = bounds.height + mb
        end
      end
      client_top = bounds.height + mb
    end
    
    move_down 20
    
    text "Total: #{Activity.total_value(activities)}", :size => 14
    
    render
  end
  
  def render_items(items, grouping, &block)
    items.group_by(&grouping).each_pair(&block)
  end
  
  def user_box(items, i, top)
    my_box(i.name, 10, 360, 20, top) do
      data = items.map(&ACTIVITY_DATA_ROW_MAPPING)
      minutes = items.inject(0, &Activity::TIME_SPENT_BLOCK)
      data << ['Total:', format_time_spent_decimal(minutes), nil, nil, Activity.total_value(items)]
      table data, TABLE_OPTIONS
    end
  end
end
