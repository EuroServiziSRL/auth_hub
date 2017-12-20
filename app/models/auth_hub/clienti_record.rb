module AuthHub
    class ClientiRecord < ActiveRecord::Base
        self.abstract_class = true
        establish_connection :"clienti_#{Rails.env}"
    end
end