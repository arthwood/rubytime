class Role < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :can_manage_financial_data, :in => [true, false]
end
