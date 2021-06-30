# -*- encoding : utf-8 -*-
require 'jwe'
require 'zip'

module AuthHub
    class IoServicesController < ApplicationController
        skip_before_action :authenticate_user!
        #chiamata con parametro client_id,tipo_login bearer token con chiave segreta
        #ritorna un jwe

        #GET get_info_login
        def get_info_service
            
            hash_return = verify_authorization
            if hash_return['esito'] == 'ok'
                #cerco in base al cf dell'ente e al nome del servizio le info del servizio 
                services_results = IoService.where("organization_fiscal_code = ? AND service_name = ?",hash_return['cf_ente'],hash_return['nome_servizio']) 
                if services_results.blank?
                    render json: { 'esito' => 'ko', 'msg_errore' => "AH: servizio con cf_ente #{hash_return['cf_ente']} e nome del servizio #{hash_return['nome_servizio']} non presente!" }
                else
                    servizio = services_results.first
                    #creo jwe
                    priv_key = OpenSSL::PKey::RSA.new(File.read(Settings.path_key_jwe))
                                        
                    payload = {
                        'organization_fiscal_code' => servizio['organization_fiscal_code'],
                        'service_name' => servizio['service_name'],
                        'service_id' => servizio['service_id'],
                        'primary_api_key' => servizio['primary_api_key']
                    }.to_json

                    encrypted = JWE.encrypt(payload, priv_key, zip: 'DEF')
                    hash_return['jwe'] = encrypted
                    hash_return['esito'] = 'ok'
                    render json: hash_return
                end
                
            else
                render json: hash_return, status: :unauthorized
            end
        end 

        

        def verify_authorization
            resp = {}
            begin
                if request.headers['Authorization'].present?
                    bearer_token = request.headers['Authorization'].split(' ').last    
                    hash_token_decoded = JsonWebToken.decode(bearer_token)
                    client_id = hash_token_decoded['cf_ente']
                    start_istant = hash_token_decoded['start']
                    #verifico istante temporale
                    if JsonWebToken.valid_token(hash_token_decoded)
                        resp['esito'] = 'ok'
                        resp['cf_ente'] = hash_token_decoded['cf_ente']
                        resp['nome_servizio'] = hash_token_decoded['nome_servizio']
                    else
                        resp['esito'] = 'ko'
                        resp['msg_errore'] = "AH: JWT non valido, controllare date (Datetime server #{Time.now}, datetime inviata #{Time.strptime(hash_token_decoded['start'],"%d%m%Y%H%M%S")})"
                    end
                else
                    resp['esito'] = 'ko'
                    resp['msg_errore'] = "AH: No authorization"
                end
                return resp
            rescue => exc
                return { 'esito' => 'ko', 'msg_errore' => "AH:: "+exc.message }
            rescue JWT::DecodeError => exc_jwt
                return { 'esito' => 'ko', 'msg_errore' => "AH:: "+exc_jwt.message }
            end
        end

        

    end
end