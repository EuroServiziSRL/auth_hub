$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "auth_hub/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "auth_hub"
  s.version     = AuthHub::VERSION
  s.authors     = ["fabianopavan"]
  s.email       = ["fabianopavan84@gmail.com"]
  s.homepage    = "http://start.soluzionipa.it/auth_hub"
  s.summary     = "AuthHub: Sistema centralizzato di login ."
  s.description = "Sistema centralizzato di login."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  
  #s.add_dependency 'email_verifier', '= 0.1.0' #PER VALIDAZIONI SU MODEL 
  #s.add_dependency "mysql2", "= 0.5.3"
  #s.add_dependency "rails", "= 5.2.4.3"
  #s.add_dependency 'config', '= 2.0.0' #PER USARE SETTINGS IN DEVISE.RB
  #s.add_dependency "devise", '= 4.6.2'
  #s.add_dependency "devise_security_extension"
  #s.add_dependency "omniauth", '= 1.9.0'
  #s.add_dependency "omniauth-azure-oauth2", '= 0.0.10'
  #s.add_dependency "adal", '= 1.0.0'
  #s.add_dependency "jwt", '= 1.5.6'
  #s.add_dependency "doorkeeper", '= 5.3.1'
  #s.add_dependency "doorkeeper-jwt", '= 0.2.1'
  
  
end
