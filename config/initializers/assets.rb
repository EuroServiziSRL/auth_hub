# #module AuthHub
#   class Engine < Rails::Engine
#     initializer :assets do |config|
#       Rails.application.config.assets.paths << root.join("app", "assets", "images", "auth_hub")
#       Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets" ,"auth_hub")
#       Rails.application.config.assets.paths << root.join("app", "assets", "javascripts" ,"auth_hub")
#       Rails.application.config.assets.precompile += %w{ main.css }
#       Rails.application.config.assets.precompile += %w{ main.js dashboard.js }
#     end
#   end
# #end

module AuthHub
    class Engine < Rails::Engine
        # initializer :assets do |config|
        #     config.assets.paths << root.join("app", "assets", "stylesheets" ,"auth_hub")
        #     config.assets.paths << root.join("app", "assets", "javascripts" ,"auth_hub")
        #     config.assets.paths << root.join("app", "assets", "images" ,"auth_hub")
        #     #config.assets.precompile += %w( auth_hub/main.scss )
        # end
        Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets" ,"auth_hub")
        Rails.application.config.assets.paths << root.join("app", "assets", "javascripts" ,"auth_hub")
        Rails.application.config.assets.paths << root.join("app", "assets", "images" ,"auth_hub")
        Rails.application.config.assets.precompile += %w( auth_hub/main.css )
    end
end