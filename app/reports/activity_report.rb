class ActivityReport < Prawn::Document
  TABLE_OPTIONS = {
    :header => true, 
#    :header_color => '86CFEF', 
#    :border_width => 1, 
#    :border_style => :grid, 
#    :border_color => 'CCCCCC', 
    :row_colors => ['FFFFFF', 'EEEEEE'],
    :column_widths => [70, 40, 150, 70, 50]
  }
  WIDTH = 540
  INDENT = 20
  ACTIVITY_DATA_ROW_MAPPING = Proc.new do |i| 
    hr = i.hourly_rate
    [i.date, Rubytime::Util.format_time_spent_decimal(i.minutes), i.comments, i.invoiced_at, hr && Rubytime::Util.format_currency_hr(hr)]
  end
  
  def my_box(title, size, width, left, top)
    bounding_box([left, top], :width => width) do
      text title, :size => size
      yield
    end
  end
  
  def to_pdf(activities, title, hide_users)
    text title, :size => 16
    
    fill_color '000000'
    
    render_items(activities, Activity::GROUP_BY_CLIENT_BLOCK) do |client, client_activities|
      my_box("Client: #{client.name}", 12, WIDTH, 0, cursor - 20) do
        render_items(client_activities, Activity::GROUP_BY_PROJECT_BLOCK) do |project, project_activities|
          my_box("Project: #{project.name}", 12, WIDTH - INDENT, 20, cursor - 10) do
            render_items(project_activities, Activity::GROUP_BY_ROLE_BLOCK) do |role, role_activities|
              my_box("Role: #{role.name}", 11, WIDTH - 2 * INDENT, 20, cursor - 10) do
                unless hide_users
                  render_items(role_activities, Activity::GROUP_BY_USER_BLOCK) do |user, user_activities|
                    user_box(user_activities, user, cursor - 10)
                  end
                end
              end
            end
          end
        end
      end
    end
    
    move_down 20
    
    text "Total: #{total_value(activities)}", :size => 14
    
    render
  end
  
  def render_items(items, grouping, &block)
    items.group_by(&grouping).each_pair(&block)
  end
  
  def user_box(items, i, top)
    my_box(i.name, 10, WIDTH - 3 * INDENT, 20, top) do
      font_size 10
      data = [['Date', 'Time', 'Comments', 'Invoiced', 'Hourly rate']]
      data.concat(items.map(&ACTIVITY_DATA_ROW_MAPPING))
      minutes = Activity.total_time(items)
      data << ['Total:', Rubytime::Util.format_time_spent_decimal(minutes), nil, nil, total_value(items)]
      table data, TABLE_OPTIONS
    end
  end
end
