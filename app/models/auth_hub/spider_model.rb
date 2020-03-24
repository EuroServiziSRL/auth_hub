module AuthHub
    class SpiderModel < ActiveRecord::Base
        
        self.abstract_class = true
        
        #The .establish_connection method returns an instance of ActiveRecord::ConnectionAdapters::ConnectionPool
        #The connection pool instance manages the connections that your application opens up to the database.
        #The default pool size is 5, although we can specify some other pool size via the optional pool:
        #Cambia dinamicamente la connessione al db in base al valore salvato nel thread corrente
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