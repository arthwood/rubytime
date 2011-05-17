class MissedActivityFilter < CustomFilter
  FIELDS = [:user_id, :period, :from, :to]
  
  attr_accessor *FIELDS
end
