module AuthHub
    class SpiderModel < ActiveRecord::Base
        
        self.abstract_class = true
        
        
        #Cambia dinamicamente la connessione
        def self.establish_connection(params)
            db_name = Thread.current[:db_name].blank? ? 'soluzionipa_new' : Thread.current[:db_name]
            default_params = { :adapter  => "mysql2",
                               :host     => Settings.host_db_server,
                               :username => Settings.username_db_server,
                               :password => Settings.password_db_server,
                               :database =>  db_name }
                
            ActiveRecord::Base.establish_connection(default_params.merge(params))
        end
    end
end