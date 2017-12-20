module AuthHub
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :"#{Rails.env}"
  end
end
