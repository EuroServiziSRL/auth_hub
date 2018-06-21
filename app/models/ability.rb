class Ability
  include CanCan::Ability
  
  #definisco cosa può fare un user
  def initialize(user)
    return if !user 
    #potrebbe avere un alias per alcune action
    #alias_action :index, :show, :to => :read
    #can :read, AuthHub::User
    #regole per superadmin che può fare tutto
    if user.superadmin_role?
      can :access,    :rails_admin
      can :manage,    :all
      cannot :utenti_servizi, AuthHub::User
    end
    if user.admin_role?
      alias_action :show, :new, :create,  :to => :creazione_utente
      alias_action :edit, :update, :destroy,  :to => :gestisci_utente
      can :utenti_servizi, AuthHub::User #lista utenti che sono admin servizi del proprio ente
      can :creazione_utente, AuthHub::User
      can :gestisci_utente, AuthHub::User
    end
  end
end
