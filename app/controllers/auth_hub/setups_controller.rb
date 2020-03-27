require_dependency "auth_hub/application_controller"

module AuthHub
  class SetupsController < ApplicationController
    before_action :set_db_name
    before_action :set_setup, only: [:show, :edit, :update, :destroy]

    #USARE:
    #https://mavens.github.io/2016/02/09/rails-multi-db
    #https://www.thegreatcodeadventure.com/managing-multiple-databases-in-a-single-rails-application/
    #

    # GET /setups
    def index
      @nome_pagina = "Lista Setup"
      unless session['ente_corrente'].blank?
        @filterrific = initialize_filterrific(Setup,	params[:filterrific] ) || return
        #filtro in base ai valori del filtro in pagina e del tipo di accesso che ho fatto
        @setups = Setup.filterrific_find(@filterrific).where('ID_ACCESSO': @current_user.sigla_ruolo).page(params[:page])
        @dati_ente = get_dati_ente
        @scrtk = Rails.application.secrets.external_auth_api_key
      else
        #vado sulla home mostrando avviso
        @avviso = "Seleziona enti"
      end
    end

    # GET /setups/1
    def show
      @nome_pagina = "Dati Setup"
    end

    # # GET /setups/new
    # def new
    #   @nome_pagina = "Nuovo Setup"
    #   @setup = Setup.new
    # end

    # GET /setups/1/edit
    def edit
      @modifica = true
      @nome_pagina = "Modifica Setup"
    end

    # # POST /setups
    # def create
    #   @setup = Setup.new(setup_params)

    #   if @setup.save
    #     redirect_to @setup, notice: 'Setup modificato con successo'
    #   else
    #     render :new
    #   end
    # end

    # PATCH/PUT /setups/1
    def update
      if @setup.update(setup_params)
        redirect_to @setup, notice: 'Setup modificato'
      else
        render :edit
      end
    end

    # DELETE /setups/1
    def destroy
      redirect_to @setup, notice: 'Non Permesso!'
      #@setup.destroy
      #redirect_to setups_url, notice: 'Setup was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_setup
        @setup = Setup.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def setup_params
        #params.fetch(:setup, {})
        params.require(:setup).permit(:VALORE)
      end
      
      #carico solo i dati dell'installazione ruby, per la parte php non serve far ripartire
      def get_installazione
          id_clienti_cliente = session['ente_corrente'].is_a?(Hash) ? session['ente_corrente']['clienti_cliente_id'] :  session['ente_corrente'].clienti_cliente_id
          #return ClientiCliente.find(id_clienti_cliente).clienti_installazioni[0]
          return ClientiInstallazione.installazione_ruby(id_clienti_cliente)[0]
         
      end
      
      #imposto il nome del db a livello di thread corrente 
      def set_db_name
        #se sono su new ho un hash, se sono su index carico oggetto
        unless session['ente_corrente'].blank?
          begin
            inst = get_installazione
            raise "Installazione non presente" if inst.blank?
            nome_db = !inst.SPIDERDB.blank? ? inst.SPIDERDB : inst.HIPPODB
            #setto nel thread il nome del db e poi chiamo la funzione del model
            Thread.current[:db_name] = nome_db
            AuthHub::Setup.establish_connection({})
          rescue => exc
            logger.error exc.message
            logger.error exc.backtrace.join("\n")
            flash[:error] = "Database non gestibile"
            redirect_to index_admin_path
          end
        end
      end
      
      #imposto il nome del db a livello di thread corrente 
      def get_dati_ente
        #se sono su new ho un hash, se sono su index carico oggetto
        inst = get_installazione
        dati_ente = {}
        dati_ente['url_ente'] = inst.SPIDERURL
        dati_ente['nome_db'] = inst.SPIDERDB
        return dati_ente
      end
      
  end
end
