module AuthHub
    class Setup < SpiderModel
      #questo model estende il model astratto SpiderModel,
      #quando con questo model si va a fare establish_connection, viene cambiato il database della connessione
      self.table_name = 'setup'
      
      # CAMPI CON TIPO
      #   element "ID", :db_column_type => "int", :length => 11
      # 	element "CR_DATE", :db_column_type => "varchar", :length => 50
      #   element "MOD_DATE", :db_column_type => "varchar", :length => 50
      #   element "CR_USER_ID", :db_column_type => "int"
      #   element "MOD_USER_ID", :db_column_type => "int"
      #   element "PERMS", :db_column_type => "varchar", :length => 50
      #   element "APPLICAZIONE", :db_column_type => "varchar", :length => 150
      # 	element "CODICE", :db_column_type => "varchar", :length => 150
      #   element "ID_TIPO", :db_column_type => "varchar", :length => 150
      #   element "ID_ACCESSO", :db_column_type => "varchar", :length => 150
      #   element "NOTE", :db_column_type => "longtext"
      #   element "VALORE", :db_column_type => "longtext"
      
    
      filterrific(
        default_filter_params: {  },
        available_filters: [ :search_query ]
      )
  
    
      scope :search_query, lambda { |query|
        return nil  if query.blank?
        # condition query, parse into individual keywords
        terms = query.downcase.split(/\s+/)
        # replace "*" with "%" for wildcard searches,
        # append '%', remove duplicate '%'s
        terms = terms.map { |e| ('%'+e.gsub('*', '%') + '%').gsub(/%+/, '%')}
            # configure number of OR conditions for provision
            # of interpolation arguments. Adjust this if you
            # change the number of OR conditions.
            num_or_conditions = 3
            where( terms.map {
          	  or_clauses = [
          	    "LOWER(applicazione) LIKE ?",
          	    "LOWER(codice) LIKE ?",
          	    "LOWER(valore) LIKE ?"
          	  ].join(' OR ')
          	  "(#{ or_clauses })"
          	}.join(' AND '),*terms.map { |e| [e] * num_or_conditions }.flatten)
        
      }
    
     
    end
end