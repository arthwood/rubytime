class ActivityFilter
  attr_accessor :id, :user_id, :project_id, :period, :from, :to, :include
  
  def initialize(params)
    params.each do |k, v|
      send "#{k}=", v
    end
  end
end
