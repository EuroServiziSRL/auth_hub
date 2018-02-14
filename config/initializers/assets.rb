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
        Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets" ,"auth_hub")
        Rails.application.config.assets.paths << root.join("app", "assets", "javascripts" ,"auth_hub")
        Rails.application.config.assets.paths << root.join("app", "assets", "images" ,"auth_hub")
        Rails.application.config.assets.precompile += %w{ main.css }
    end
end