$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "auth_hub/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "auth_hub"
  s.version     = AuthHub::VERSION
  s.authors     = ["fabianopavan"]
  s.email       = ["fabianopavan84@gmail.com"]
  s.homepage    = "http://www.soluzionipa.it/auth_hub"
  s.summary     = "Summary of AuthHub."
  s.description = "Description of AuthHub."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  
  s.add_dependency 'email_verifier' #PER VALIDAZIONI SU MODEL 
  s.add_dependency "mysql2", "= 0.4.10"
  s.add_dependency "rails", "= 5.2.0"
  s.add_dependency 'config' #PER USARE SETTINGS IN DEVISE.RB
  #COMMENTATE FIN CHE NON SISTEMO GEMMA devise_security_extension, DA FARE
  s.add_dependency "devise"
  s.add_dependency "devise_security_extension"
  s.add_dependency "omniauth"
  s.add_dependency "omniauth-azure-oauth2"
  s.add_dependency "adal"
  s.add_dependency "jwt"
  
  
end
