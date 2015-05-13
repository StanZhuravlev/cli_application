class Offer < ActiveRecord::Base
  self.establish_connection self.configurations[:default]
  self.table_name = "offers_table"

end