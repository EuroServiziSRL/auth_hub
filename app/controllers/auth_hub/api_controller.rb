# -*- encoding : utf-8 -*-
require 'jwe'

module AuthHub
    class ApiController < ApplicationController
        skip_before_action :authenticate_user!
        #chiamata con parametro client_id,tipo_login bearer token con chiave segreta
        #ritorna un jwe

        #GET get_info_login
        def get_info_login_cliente
            hash_return = verify_authorization
            if hash_return['esito'] == 'ok'
                #cerco in base al client_id le info 
                info_cliente_results = InfoLoginCliente.where("client = ?",hash_return['client_id']) 
                if info_cliente_results.blank?
                    render json: { 'esito' => 'ko', 'msg_errore' => "AH: cliente con client_id #{hash_return['client_id']} non presente!" }
                else
                    info_cliente = info_cliente_results.first
                    #controllo se al cliente è stato attivato il tipo di login richiesto
                    case hash_return['tipo_login']
                    when 'cie'
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login non abilitato" } unless info_cliente.cie 
                    when 'spid'
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login non abilitato" } unless info_cliente.spid 
                    when 'eidas'
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login non abilitato" } unless info_cliente.eidas 
                    else    
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login richiesto non specificato" }
                    end
                    #creo jwe
                    priv_key = OpenSSL::PKey::RSA.new(File.read(Settings.path_key_jwe))
                    #leggo certificato, comprimo e metto in base64
                    path_cert = "#{Rails.root}/data/certs_clienti/cert_path/#{info_cliente['client']}/#{info_cliente['cert_path']}"
                    cert_deflate = Zlib::Deflate.deflate(File.read(path_cert))
                    #leggo chiave, comprimo e metto in base64
                    path_key = "#{Rails.root}/data/certs_clienti/key_path/#{info_cliente['client']}/#{info_cliente['key_path']}"
                    key_deflate = Zlib::Deflate.deflate(File.read(path_key))
                    
                    payload = {
                        'client' => info_cliente['client'],
                        'secret' => info_cliente['secret'],
                        'url_app_ext' => info_cliente['url_app_ext'],
                        'url_ass_cons_ext' => info_cliente['url_ass_cons_ext'],
                        'issuer' => info_cliente['issuer'],
                        'org_name' => info_cliente['org_name'],
                        'org_display_name' => info_cliente['org_display_name'],
                        'org_url' => info_cliente['org_url'],
                        'key_b64' => Base64.strict_encode64(key_deflate),
                        'cert_b64' => Base64.strict_encode64(cert_deflate),
                        'app_ext' => info_cliente['app_ext']
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
                    client_id = hash_token_decoded['client_id']
                    start_istant = hash_token_decoded['start']
                    #verifico istante temporale
                    if JsonWebToken.valid_token(hash_token_decoded)
                        resp['esito'] = 'ok'
                        resp['client_id'] = hash_token_decoded['client_id']
                        resp['tipo_login'] = hash_token_decoded['tipo_login']
                    else
                        resp['esito'] = 'ko'
                        resp['msg_errore'] = "AH: Richiesta in timeout"
                    end
                else
                    resp['esito'] = 'ko'
                    resp['msg_errore'] = "AH: No authorization"
                end
                return resp
            rescue => exc
                return { 'esito' => 'ko', 'msg_errore' => "AH: "+exc.message }
            rescue JWT::DecodeError => exc_jwt
                return { 'esito' => 'ko', 'msg_errore' => "AH: "+exc_jwt.message }
            end
        end

        

    end
end