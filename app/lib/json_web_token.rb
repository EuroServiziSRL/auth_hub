class JsonWebToken
    class << self
        def encode(payload, secret=nil, alg=nil)
            JWT.encode(payload, Rails.application.secrets.external_auth_api_key,'HS256')
        end
   
        def decode(token) 
            body = JWT.decode(token, Rails.application.secrets.external_auth_api_key,'HS256')[0] 
            HashWithIndifferentAccess.new body 
        rescue 
            nil 
        end
        
        
        
        
        # Validates the payload hash for expiration and meta claims
        def valid_payload(payload)
            if expired(payload) || payload['iss'] != meta[:iss] || payload['aud'] != meta[:aud]
              return false
            else
              return true
            end
        end
  
        def valid_token(decoded_token)
            #lo start deve essere non più vecchio di 10 minuti
            data_valida = (DateTime.strptime(decoded_token['start'],"%d%m%Y%H%M%S") > (DateTime.now.new_offset(0)-(((1.0/24)/60)*10)) )
        end

    end
end
