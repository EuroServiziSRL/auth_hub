module AuthHub
    class TenantProvider
      def initialize(strategy)
        @strategy = strategy
      end
    
      def client_id
        tenant.azure_client_id
      end
    
      def client_secret
        tenant.azure_client_secret
      end
    
      def tenant_id
        tenant.azure_tenant_id
      end
    
      def domain_hint
        tenant.azure_domain_hint
      end
      
      private 
    
      def tenant
        # whatever strategy you want to figure out the right tenant from params/session
        #BISOGNA CREARE UN MODELLO (tabella clienti) CON QUESTI CAMPI PER USARE L'OGGETTO E PASSARLO PER I CAMPI
        #@tenant ||= Customer.find(@strategy.session[:customer_id])
      end
     
      
      
    end
end