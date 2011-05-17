class ActivityFilter < CustomFilter
  FIELDS = [:user_id, :project_id, :client_id, :period, :from, :to, :invoice_filter]
  
  attr_accessor *FIELDS
end
