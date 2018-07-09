require_dependency "auth_hub/application_controller"

#controller per gestire utenti tramite superadmin e admin

module AuthHub
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :set_ente
    
    #serve per le autorizzazioni di cancancan
    load_and_authorize_resource :class => "AuthHub::User"



    # GET /users
    def index
      @nome_pagina = "Lista Utenti"
      @filterrific = initialize_filterrific(User,	params[:filterrific] ) or return
      @users = @filterrific.find.page(params[:page])
      
      respond_to do |format|
      	format.html
      	format.js
      end
    end

    
    # GET /users/utenti_da_confermare
    def utenti_da_confermare
      #controllo se viene passata chiave stato
      
      @nome_pagina = "Lista Utenti Da Confermare"
      #@filterrific = initialize_filterrific(User,	params[:filterrific], available_filters: [:search_query, :utenti_stato_non], default_filter_params: {stato: 'confermato'} ) or return
      @filterrific = initialize_filterrific(User,	params[:filterrific] ) or return
      @users = User.filterrific_find(@filterrific).where.not(stato: 'confermato').page(params[:page])
      
      respond_to do |format|
      	format.html { render :index }
      	format.js { render :index }
      end
    end

    #lista utenti che sono admin servizi del proprio ente
    # GET /users/utenti_servizi
    def utenti_servizi
      #controllo se viene passata chiave stato
      @nome_pagina = "Lista Utenti per Servizi"
      @filterrific = initialize_filterrific(User,	params[:filterrific] ) or return
      #faccio join su tabella enti_gestiti e carico il cliente con id uguale al cliente corrente
      @users = User.filterrific_find(@filterrific).joins(:enti_gestiti).where('admin_role' => false,'auth_hub_enti_gestiti.clienti_cliente_id' => @ente_principale.clienti_cliente.id  ).page(params[:page])
      
      respond_to do |format|
      	format.html { render :index }
      	format.js { render :index }
      end
    end



    # GET /users/1
    def show
      @nome_pagina = "Dati Utente"
    end

    # GET /users/new
    def new
      @user = User.new
      @nome_pagina = "Nuovo Utente"
    end

    # GET /users/1/edit
    def edit
      @modifica = true
      @nome_pagina = "Modifica Dati Utente"
    end

    # POST /users
    def create
      @user = User.new(user_params)
      #se sono un admin e creo un admin servizi devo passargli l'ente corrente dell'admin
      if @user.save(context: :new_e_update_da_admin)
        if @current_user.admin_role? && !@ente_principale.blank?
          if @user.admin_servizi?
            ente_da_associare = EnteGestito.new
            ente_da_associare.user = @user
            ente_da_associare.principale = true
            ente_da_associare.clienti_cliente = @ente_principale.clienti_cliente
            ente_da_associare.save
          end
        end
        redirect_to @user, notice: 'Utente registrato con successo.'
      else
        render :new
      end
    end

    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        redirect_to @user, notice: 'Utente modificato con successo.'
      else
        render :edit
      end
    end

    # DELETE /users/1
    def destroy
      @user.destroy
      redirect_to users_url, notice: 'Utente cancellato con successo.'
    end

    #Vedo gli enti associati ad un utente e la select per associarne di nuovi (select multipla)
    # GET /users/1/associa_enti
    def associa_enti
      @nome_pagina = "Associa Enti ad Amministratore"
      @esito = flash['esito'] unless flash.blank?
      @utente_selezionato = User.find(params[:id])
      enti_associati = @utente_selezionato.enti_gestiti.map{|ente| ente.clienti_cliente_id} if @utente_selezionato.enti_gestiti.length > 0
      if enti_associati.blank?
        @enti = ClientiCliente.all.order("CLIENTE asc")
      else
        @enti = ClientiCliente.where( "clienti__cliente.ID not IN (?)", enti_associati).order("CLIENTE asc")
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
      
      def set_ente
        @array_enti_gestiti = session['array_enti_gestiti'] unless session['array_enti_gestiti'].blank?
        @ente_principale = EnteGestito.find(session['ente_corrente']['id']) unless session['ente_corrente'].blank?
      end

      # dei parametri che mi arrivano permetto che passino solo alcuni
      def user_params
        params['user']['stato'] = 'confermato' if params['user']['stato'] == '1'
        params.require(:user).permit(:email,:password,:password_confirmation,:nome,:cognome,:nome_cognome,:admin_role,:admin_servizi,:stato)
      end
  end
end
