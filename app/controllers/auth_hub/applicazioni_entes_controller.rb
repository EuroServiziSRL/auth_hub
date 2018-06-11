require_dependency "auth_hub/application_controller"

module AuthHub
  class ApplicazioniEntesController < ApplicationController
    before_action :set_applicazioni_ente, only: [:show, :edit, :update, :destroy]

    # GET /applicazioni_ente
    def index
      @applicazioni_ente = ApplicazioniEnte.all
    end

    # GET /applicazioni_ente/1
    def show
    end

    # GET /applicazioni_ente/new
    def new
      @applicazioni_ente = ApplicazioniEnte.new
    end

    # GET /applicazioni_ente/1/edit
    def edit
    end

    # POST /applicazioni_ente
    def create
      @applicazioni_ente = ApplicazioniEnte.new(applicazioni_ente_params)

      if @applicazioni_ente.save
        redirect_to @applicazioni_ente, notice: 'Applicazioni ente was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /applicazioni_ente/1
    def update
      if @applicazioni_ente.update(applicazioni_ente_params)
        redirect_to @applicazioni_ente, notice: 'Applicazioni ente was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /applicazioni_ente/1
    def destroy
      id_ente_gestito = @applicazioni_ente.ente_id
      @applicazioni_ente.destroy
      #faccio la redirect alla pagina di associazione ente-applicazione 
      redirect_to vedi_applicazione_ente_gestito_path(id: id_ente_gestito), notice: 'Associazione Cancellata'
      #redirect_to applicazioni_ente_index_url, notice: 'Applicazioni ente was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_applicazioni_ente
        @applicazioni_ente = ApplicazioniEnte.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def applicazioni_ente_params
        params.fetch(:applicazioni_ente, {})
      end
  end
end
