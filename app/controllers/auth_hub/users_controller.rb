require_dependency "auth_hub/application_controller"

#controller per gestire utenti tramite superadmin e admin

module AuthHub
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    load_and_authorize_resource :class => "AuthHub::User"

    # GET /users
    def index
      #@users = User.all
      @filterrific = initialize_filterrific(
	User,
	params[:filterrific]
      ) or return
      @students = @filterrific.find.page(params[:page])
    end

    # GET /users/1
    def show
    end

    # GET /users/new
    def new
      @user = User.new
    end

    # GET /users/1/edit
    def edit
    end

    # POST /users
    def create
      #password_diverse = user_params['conferma_password'] != user_params['password']
      
      @user = User.new(user_params)
      #@user.errors.add(:password, :blank, message: "Le due password devono coincidere") if password_diverse
        
      if @user.save
        redirect_to @user, notice: 'User was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /users/1
    def destroy
      @user.destroy
      redirect_to users_url, notice: 'User was successfully destroyed.'
    end

    #Vedo gli enti associati ad un utente e la select per associarne di nuovi (select multipla)
    # GET /users/1/associa_enti
    def associa_enti
      @esito = flash['esito'] unless flash.blank?
      @utente_selezionato = User.find(params[:id])
      enti_associati = @utente_selezionato.enti_gestiti.map{|ente| ente.clienti_cliente_id} if @utente_selezionato.enti_gestiti.length > 0
      if enti_associati.blank?
        @enti = ClientiCliente.all
      else
        @enti = ClientiCliente.where( "clienti__cliente.ID not IN (?)", enti_associati)
      end
      
    end

    #Metodo che fa l'associazione tra user e ente (clienti_cliente)
    # POST /users/1/salva_enti_associati
    def salva_enti_associati
      @utente_selezionato = User.find(params[:id])
      #arrivano gli enti params['enti_da_associare'] => ["5", "6", "7"]
      enti_da_associare = params['enti_da_associare']
      if enti_da_associare.blank?
        redirect_to({ action: 'associa_enti'}, notice: 'Selezionare almeno un ente')
      else
        #associo gli enti
        enti_da_associare.each{ |id_ente|
          ente_da_associare = ClientiCliente.find(id_ente)
          EnteGestito.create(user: @utente_selezionato, clienti_cliente: ente_da_associare)
        }
        redirect_to({ action: 'associa_enti'}, :flash => { :esito => "Enti associati con successo." })
      end
      
      
    end


    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # dei parametri che mi arrivano permetto che passino solo alcuni
      def user_params
        params.require(:user).permit(:email,:password,:password_confirmation,:nome,:cognome,:nome_cognome,:admin_role,:admin_servizi)
      end
  end
end
