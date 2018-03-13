class Ability
  include CanCan::Ability
  
  #definisco cosa può fare un user
  def initialize(user)
    return if !user 
    #regole per superadmin che può fare tutto
    if user.superadmin_role?
      can :access,    :rails_admin
      can :manage,    :all
    end
    if user.admin_role?
      can :manage,    :all
    end
  end
end
