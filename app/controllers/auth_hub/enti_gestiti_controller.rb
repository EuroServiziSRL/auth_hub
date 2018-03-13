require_dependency "auth_hub/application_controller"

module AuthHub
  class EntiGestitiController < ApplicationController
    before_action :set_ente_gestito, only: [:show, :edit, :update, :destroy]

    # GET /enti_gestiti
    def index
      @enti_gestiti = EnteGestito.all
    end

    # GET /enti_gestiti/1
    def show
    end

    # GET /enti_gestiti/new
    def new
      @ente_gestito = EnteGestito.new
    end

    # GET /enti_gestiti/1/edit
    def edit
    end

    # POST /enti_gestiti
    def create
      @ente_gestito = EnteGestito.new(ente_gestito_params)

      if @ente_gestito.save
        redirect_to @ente_gestito, notice: 'Ente gestito was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /enti_gestiti/1
    def update
      if @ente_gestito.update(ente_gestito_params)
        redirect_to @ente_gestito, notice: 'Ente gestito was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /enti_gestiti/1
    def destroy
      id_user = @ente_gestito.user_id
      @ente_gestito.destroy
      #faccio la redirect alla pagina di associazione utenti-ente 
      redirect_to associa_enti_user_path(id: id_user), notice: 'Associazione Cancellata'
      #redirect_to enti_gestiti_url, notice: 'Ente gestito was successfully destroyed.'
    end
    
    
    #view per associare una o più applicazioni ad un ente gestito 
    def gestisci_applicazione_ente_gestito
      @ente_gestito = EnteGestito.find(params[:id])
      #posso usare anche lo scope
      #applicazioni_associate = ApplicazioniEnte.dell_ente(@ente_gestito.id).map{|app| app.id} if ApplicazioniEnte.dell_ente(@ente_gestito.id).length > 0
      applicazioni_associate = @ente_gestito.applicazioni_ente.map{|app| app.id} if @ente_gestito.applicazioni_ente.length > 0
      if applicazioni_associate.blank?
        @enti = ClientiApplicazione.all
      else
        @enti = ClientiApplicazione.where( "clienti__applicazione.ID not IN (?)", applicazioni_associate)
      end
    end
  

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ente_gestito
        @ente_gestito = EnteGestito.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ente_gestito_params
        params.require(:ente_gestito).permit(:destroy, :show)
      end
  end
end
