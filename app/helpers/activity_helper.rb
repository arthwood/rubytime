module ActivityHelper
  def total_value(activities)
    Activity.total_value(activities).join(' + ')
  end
  
  def total_time(activities)
    Activity.total_time(activities)
  end
end
