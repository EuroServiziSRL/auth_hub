# -*- encoding : utf-8 -*-
require 'jwe'
require 'zip'

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
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login non abilitato" } and return unless info_cliente.cie 
                    when 'spid'
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login non abilitato" } and return unless info_cliente.spid 
                    when 'eidas'
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login non abilitato" } and return unless info_cliente.eidas 
                    else    
                        render json: { 'esito' => 'ko', 'msg_errore' => "AH: Tipo di login richiesto non specificato" } and return
                    end
                    #creo jwe
                    priv_key = OpenSSL::PKey::RSA.new(File.read(Settings.path_key_jwe))
                    
                    #Se richiedo login cie oppure sono con con spid/eidas e non sono cliente aggregato
                    if hash_return['tipo_login'] == 'cie' || !info_cliente.aggregato
                        #leggo certificato, comprimo e metto in base64
                        path_cert = "#{Rails.root}/data/certs_clienti/cert_path/#{info_cliente['client']}/#{info_cliente['cert_path']}"
                        if !info_cliente['cert_path'].blank? && File.exists?(path_cert)
                            cert_deflate = Zlib::Deflate.deflate(File.read(path_cert))
                            cert_b64 = Base64.strict_encode64(cert_deflate)
                        else 
                            render json: { 'esito' => 'ko', 'msg_errore' => "AH: Certificato per client #{info_cliente['client']} mancante!" } and return
                        end
                        #leggo chiave, comprimo e metto in base64
                        path_key = "#{Rails.root}/data/certs_clienti/key_path/#{info_cliente['client']}/#{info_cliente['key_path']}"
                        if !info_cliente['key_path'].blank? && File.exists?(path_key)
                            key_deflate = Zlib::Deflate.deflate(File.read(path_key)) 
                            key_b64 = Base64.strict_encode64(key_deflate)
                        else 
                            render json: { 'esito' => 'ko', 'msg_errore' => "AH: Chiave per client #{info_cliente['client']} mancante!" } and return
                        end
                    else
                        cert_b64 = nil
                        key_b64 = nil
                    end                    
                    
                    payload = {
                        'client' => info_cliente['client'],
                        'secret' => info_cliente['secret'],
                        'url_app_ext' => info_cliente['url_app_ext'],
                        'url_ass_cons_ext' => info_cliente['url_ass_cons_ext'],
                        'issuer' => info_cliente['issuer'],
                        'org_name' => info_cliente['org_name'],
                        'org_display_name' => info_cliente['org_display_name'],
                        'org_url' => info_cliente['org_url'],
                        'key_b64' => key_b64,
                        'cert_b64' => cert_b64,
                        'app_ext' => info_cliente['app_ext'],
                        'spid' => info_cliente['spid'],
                        'cie' => info_cliente['cie'],
                        'eidas' => info_cliente['eidas'],
                        'spid_pre_prod' => info_cliente['spid_pre_prod'],
                        'cie_pre_prod' => info_cliente['cie_pre_prod'],
                        'eidas_pre_prod' => info_cliente['eidas_pre_prod'],
                        'aggregato' => info_cliente['aggregato'],
                        'cod_ipa_aggregato' => info_cliente['cod_ipa_aggregato'],
                        'p_iva_aggregato' => info_cliente['p_iva_aggregato'],
                        'cf_aggregato' => info_cliente['cf_aggregato'],
                        'email_aggregato' => info_cliente['email_aggregato'],
                        'telefono_aggregato' => info_cliente['telefono_aggregato']
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

        # La comunicazione del metadata può essere effettuata esclusivamente i giorni
        # lunedì, mercoledì e venerdì (se feriali) entro e non oltre le ore 15 con un'unica
        # mail giornaliera, con oggetto “[Metadata Aggregatori]”, contenente, in un unico
        # file ZIP in allegato:
        # - un file XML per ogni metadata nuovo o aggiornato;
        # - un file JSON riepilogativo dei dati degli Aggregati interessati.

        #zip con metadata singoli in xml e un json riepilogativo API        
        def genera_zip_metadata
            hash_risultato = self.class._genera_zip_metadata
            render json: hash_risultato 
        end


        


        #zip con metadata singoli in xml e un json riepilogativo METODO INTERNO
        def self._genera_zip_metadata
            info_cliente_results = InfoLoginCliente.where("stato_metadata <> ? AND aggregato = ? AND spid = ?","inviato", true, true)
            unless info_cliente_results.blank?
                #file zip che viene inviato ad agid, viene salvato sulla data
                dir_zip_metadata = "#{Rails.root}/data/metadata_aggregati"
                Dir.mkdir(dir_zip_metadata) unless File.exists?(dir_zip_metadata) 
                file_zip_path = "#{dir_zip_metadata}/md-aggr-#{Settings.hash_aggregatore['piva_aggregatore']}-#{Time.now.strftime('%Y%m%d')}.zip"
                zip_file = File.new(file_zip_path, 'w')
                #creo uno zip mettendoci dentro il valore della response che arriva
                Zip::OutputStream.open(zip_file.path) do |zip|
                    #oggetto per manifest json
                    array_metadati = []
                    info_cliente_results.each{ |info_cliente| 
                        #creo jwe
                        priv_key = OpenSSL::PKey::RSA.new(File.read(Settings.path_key_jwe))
                        payload = {
                            'client' => info_cliente['client'],
                            'secret' => info_cliente['secret'],
                            'url_app_ext' => info_cliente['url_app_ext'],
                            'url_ass_cons_ext' => info_cliente['url_ass_cons_ext'],
                            'url_metadata_ext' => info_cliente['url_metadata_ext'],
                            'issuer' => info_cliente['issuer'],
                            'org_name' => info_cliente['org_name'],
                            'org_display_name' => info_cliente['org_display_name'],
                            'org_url' => info_cliente['org_url'],
                            'app_ext' => info_cliente['app_ext'],
                            'spid_pre_prod' => info_cliente['spid_pre_prod'],
                            'cie_pre_prod' => info_cliente['cie_pre_prod'],
                            'eidas_pre_prod' => info_cliente['eidas_pre_prod'],
                            'aggregato' => info_cliente['aggregato'],
                            'cod_ipa_aggregato' => info_cliente['cod_ipa_aggregato'],
                            'p_iva_aggregato' => info_cliente['p_iva_aggregato'],
                            'cf_aggregato' => info_cliente['cf_aggregato'],
                            'email_aggregato' => info_cliente['email_aggregato'],
                            'telefono_aggregato' => info_cliente['telefono_aggregato']
                        }.to_json
                        encrypted = JWE.encrypt(payload, priv_key, zip: 'DEF')
                        response = HTTParty.get(File.join(Settings.app_auth_url,"spid/get_metadata"),
                            :headers => { 'Authorization' => "Bearer #{encrypted}" },
                            :body => { 'client_id' => info_cliente['client'], 'zip' => 'true'},
                            :follow_redirects => false,
                            :timeout => 500 )
                        unless response.blank?
                            if response['esito'] == 'ok'
                                begin
                                    array_metadati << {
                                        'action': info_cliente.get_stato_manifest,
                                        'entityCode': info_cliente.cod_ipa_aggregato,
                                        'entityName': info_cliente.org_name,
                                        'entityID': info_cliente.issuer,
                                        'isPrivate': (info_cliente.cod_ipa_aggregato.blank? ? true : false),
                                        'metadataFilename': "#{info_cliente.cod_ipa_aggregato}__#{Settings.hash_aggregatore['piva_aggregatore']}.xml"
                                    }
                                    #se faccio una DELETE non metto metadataUrl
                                    if info_cliente.get_stato_manifest != "DELETE" 
                                        array_metadati.last['metadataUrl'] = (info_cliente.url_metadata_ext.blank? ? info_cliente.org_url+"/portal/auth/spid/sp_metadata" : info_cliente.url_metadata_ext)
                                    end
                                    zip.put_next_entry("#{(info_cliente.cod_ipa_aggregato.blank? ? info_cliente.p_iva_aggregato : info_cliente.cod_ipa_aggregato)}__#{Settings.hash_aggregatore['piva_aggregatore']}.xml")
                                    zip.puts response['metadata']
                                rescue => exc
                                    logger.error  "AH: Problemi recupero metadata di #{info_cliente['org_name']}"
                                    logger.error exc.message
                                    logger.error exc.backtrace.join("\n")
                                    #render json: { 'esito' => 'ko', 'msg_errore' => "AH: Problemi recupero metadata di #{info_cliente['org_name']}" }
                                end
                            else
                                logger.error "Errore in genera_zip_metadata SPID: #{response['msg_errore']}"
                                raise "Metadata aggregato non completo"
                                #render json: { 'esito' => 'ko', 'msg_errore' => "Non ci sono metadati da aggiornare" }
                            end                        
                        else
                            raise "Servizio non disponibile"
                        end
                    } #fine ciclo su metadata da inviare ad agid
                    hash_manifest = {
                        'aggregatorCode': Settings.hash_aggregatore['piva_aggregatore'],
                        'aggregatorName': Settings.hash_aggregatore['soggetto_aggregatore'],
                        'entityID': Settings.hash_aggregatore['entity_id'],
                        'dateTime': Time.now.strftime('%Y-%m-%dT%H:%M:%S'),
                        'metadata': array_metadati
                    }
                    zip.put_next_entry("md-aggr-#{Settings.hash_aggregatore['piva_aggregatore']}-#{Time.now.strftime('%Y%m%d')}.json")
                    zip.puts JSON.pretty_generate(hash_manifest)
                end
                return { 'esito' => 'ok', 'msg' => "Metadata generati", 'path_zip' => file_zip_path }
            else
                return { 'esito' => 'ko', 'msg_errore' => "Non ci sono metadati da aggiornare" }
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