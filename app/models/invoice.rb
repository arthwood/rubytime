require 'fastercsv'
require 'reports/invoice_report'

class Invoice < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :client
  belongs_to :user
  
  has_many :activities, :dependent => :nullify, :include => [:project, :user]
  
  default_scope :order => :name

  def to_csv
    FasterCSV.generate do |csv|
      csv << ['Date', 'Project', 'Person', 'Time Spent', 'Comments', 'Price']
      activities.each do |i|
        csv << i.to_csv_row
      end
      csv << [nil, nil, nil, nil, 'Total:', "#{Activity.total_price(activities)}"]
    end
  end
  
  def to_pdf
    InvoiceReport.new.to_pdf(self)
  end
end
