module AuthHub
  class Engine < ::Rails::Engine
    isolate_namespace AuthHub
    
    #aggiunto per usare migration a livello di suite openweb
    initializer :append_migrations do |app|
      unless app.root.to_s.match(root.to_s)
        config.paths["db/migrate"].expanded.each do |p|
          app.config.paths["db/migrate"] << p
        end
      end
    end
  
    # Indica se con il logout dall'app rails o da app esterna si fa anche la logout da Oauth Azure
    #config.logout_azure = false #=> uso config.yml in applicazione master
    
  end
  
end
