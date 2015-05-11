class Tovar < ActiveRecord::Base
  self.establish_connection self.configurations[:default]
  self.table_name = "modx_vs_vs_tovar"

end