module AuthHub
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :"#{Rails.env}"  #cambia all'inizio il database
    
    #Per cambio dinamico della connessione
    def self.establish_connection(params=nil)
        config   = Rails.configuration.database_configuration
        host     = config[Rails.env]["host"]
        database = config[Rails.env]["database"]
        username = config[Rails.env]["username"]
        password = config[Rails.env]["password"]
        default_params = { :adapter  => "mysql2",
          :host     => host,
          :username => username,
          :password => password,
          :database => database }
        ActiveRecord::Base.establish_connection(default_params)
    end
    
      
  
  
  end
end
