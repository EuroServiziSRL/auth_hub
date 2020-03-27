Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (needs plugins)
  orm :active_record

  #USA doorkeeper solo per api
  api_only

  # This block will be called to check whether the resource owner is authenticated or not.
  
  
  resource_owner_authenticator do
    fail "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by_id(session[:user_id]) || redirect_to(new_user_session_url)
  end

  # In this flow, a token is requested in exchange for the resource owner credentials (username and password)
  #Viene fatta l'autenticazione con la tabella users
  resource_owner_from_credentials do |routes|
    
    #Extra controlli con basic auth, si potrebbe usare client_id e secret di pagamenti
    # # Since we are using Basic Authorizaion we parse the Authorization header
    # # and check if the credentials are valid by fetching the application
    # # matching those credentials
    # authorization = request.authorization
    # if authorization.present? && authorization =~ /^Basic (.*)/m
    #   credentials = Base64.decode64(Regexp.last_match[1]).split(/:/, 2)
    #   uid         = credentials.first
    #   secret      = credentials.second
    #   application = Doorkeeper::Application.by_uid_and_secret uid, secret
    # end
    
    
    #AuthHub::User.establish_connection({})
    user = AuthHub::User.find_for_database_authentication(:email => params[:username])
    if user && user.valid_for_authentication? { user.valid_password?(params[:password]) }
      user
    end
  end


  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  # admin_authenticator do
  #   # Put your admin authentication logic here.
  #   # Example implementation:
  #   Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
  # end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  access_token_expires_in 1800.seconds

  # Assign a custom TTL for implicit grants.
  # custom_access_token_expires_in do |oauth_client|
  #   oauth_client.application.additional_settings.implicit_oauth_expiration
  # end

  # Use a custom class for generating the access token.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
  access_token_generator '::Doorkeeper::JWT'

  # The controller Doorkeeper::ApplicationController inherits from.
  # Defaults to ActionController::Base.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
  #base_controller 'AuthHub::ApplicationController'

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  #reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter confirmation: true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  # enable_application_owner confirmation: false

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write, :update

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out https://github.com/doorkeeper-gem/doorkeeper/wiki/Changing-how-clients-are-authenticated
  # for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out https://github.com/doorkeeper-gem/doorkeeper/wiki/Changing-how-clients-are-authenticated
  # for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  # Callable objects such as proc, lambda, block or any object that responds to
  # #call can be used in order to allow conditional checks (to allow non-SSL
  # redirects to localhost for example).
  #
  # force_ssl_in_redirect_uri !Rails.env.development?
  #
  # force_ssl_in_redirect_uri { |uri| uri.host != 'localhost' }

  # Specify what redirect URI's you want to block during creation. Any redirect
  # URI is whitelisted by default.
  #
  # You can use this option in order to forbid URI's with 'javascript' scheme
  # for example.
  #
  # forbid_redirect_uri { |uri| uri.scheme.to_s.downcase == 'javascript' }

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #
  # grant_flows %w[authorization_code client_credentials]

  grant_flows %w(password)

  # Hook into the strategies' request & response life-cycle in case your
  # application needs advanced customization or logging:
  #
  # before_successful_strategy_response do |request|
  #   puts "BEFORE HOOK FIRED! #{request}"
  # end
  #
  # after_successful_strategy_response do |request, response|
  #   puts "AFTER HOOK FIRED! #{request}, #{response}"
  # end

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  skip_authorization do |resource_owner, client|
    client.superapp? or resource_owner.admin?
  end
  
  # skip_authorization do
  #   true
  # end

  # WWW-Authenticate Realm (default "Doorkeeper").
  # realm "Doorkeeper"
end


Doorkeeper::JWT.configure do
  # Set the payload for the JWT token. This should contain unique information
  # about the user.
  # Defaults to a randomly generated token in a hash
  # { token: "RANDOM-TOKEN" }
  token_payload do |opts|
    #AuthHub::User.establish_connection({})
    user = AuthHub::User.find(opts[:resource_owner_id])
    princ = AuthHub::EnteGestito.ente_principale_da_user(user.id)
    nome_db = nil
    princ[0].clienti_cliente.clienti_installazioni.each{|installazione|
      #trova installazione su server ruby
      nome_db = installazione.SPIDERDB unless installazione.SPIDERDB.blank?
    }
    jti = SecureRandom.uuid
    client_id = OpenSSL::Digest::SHA256.new(nome_db+jti)
    {
      'iss': 'auth_hub',
      'iat': Time.current.utc.to_i, #Issued At, datetime di creazione jwt
      'exp': (Time.current.utc+1800).to_i, #Expiration time: durata di 30secondi
      'jti': jti, # @see JWT reserved claims - https://tools.ietf.org/html/draft-jones-json-web-token-07#page-7 
      'client_id': client_id,
      'user': {
        'id': user.id,
        'email': user.email,
        'nome': user.nome,
        'cognome': user.cognome
      }
    }
  end

  # Optionally set additional headers for the JWT. See https://tools.ietf.org/html/rfc7515#section-4.1
  # token_headers do |opts|
  #   {
  #     kid: opts[:application][:uid]
  #   }
  # end

  # Use the application secret specified in the Access Grant token
  # Defaults to false
  # If you specify `use_application_secret true`, both secret_key and secret_key_path will be ignored
  use_application_secret false

  # Set the encryption secret. This would be shared with any other applications
  # that should be able to read the payload of the token.
  # Defaults to "secret"
  secret_key Rails.application.secrets.external_auth_api_key

  # If you want to use RS* encoding specify the path to the RSA key
  # to use for signing.
  # If you specify a secret_key_path it will be used instead of secret_key
  #secret_key_path File.join('path', 'to', 'file.pem')

  # Specify encryption type. Supports any algorithm in
  # https://github.com/progrium/ruby-jwt
  # defaults to nil
  encryption_method :hs256
end

#Errore personalizzato
Doorkeeper::OAuth::ErrorResponse.send :prepend, CustomTokenErrorResponse

#HO DOVUTO RIDEFINIRE IL CONTROLLER TokensController per connettere al corretto db activerecord durante la creazione del token

module Doorkeeper
  class TokensController < Doorkeeper::ApplicationMetalController
    def create
      #imposto la connessione che deve sempre usare la parte jwt
      config   = ::Rails.configuration.database_configuration
      host     = config[::Rails.env]["host"]
      database = config[::Rails.env]["database"]
      username = config[::Rails.env]["username"]
      password = config[::Rails.env]["password"]
      default_params = { :adapter  => "mysql2",
        :host     => host,
        :username => username,
        :password => password,
        :database => database }
      ::ActiveRecord::Base.establish_connection(default_params)
      headers.merge!(authorize_response.headers)
      render json: authorize_response.body,
             status: authorize_response.status
    rescue Errors::DoorkeeperError => e
      handle_token_exception(e)
    end

    # OAuth 2.0 Token Revocation - http://tools.ietf.org/html/rfc7009
    def revoke
      # @see 2.1.  Revocation Request
      #
      #  The client constructs the request by including the following
      #  parameters using the "application/x-www-form-urlencoded" format in
      #  the HTTP request entity-body:
      #     token   REQUIRED.
      #     token_type_hint  OPTIONAL.
      #
      #  The client also includes its authentication credentials as described
      #  in Section 2.3. of [RFC6749].
      #
      #  The authorization server first validates the client credentials (in
      #  case of a confidential client) and then verifies whether the token
      #  was issued to the client making the revocation request.
      unless server.client
        # If this validation [client credentials / token ownership] fails, the request is
        # refused and the  client is informed of the error by the authorization server as
        # described below.
        #
        # @see 2.2.1.  Error Response
        #
        # The error presentation conforms to the definition in Section 5.2 of [RFC6749].
        render json: revocation_error_response, status: :forbidden
        return
      end

      # The authorization server responds with HTTP status code 200 if the client
      # submitted an invalid token or the token has been revoked successfully.
      if token.blank?
        render json: {}, status: 200
      # The authorization server validates [...] and whether the token
      # was issued to the client making the revocation request. If this
      # validation fails, the request is refused and the client is informed
      # of the error by the authorization server as described below.
      elsif authorized?
        revoke_token
        render json: {}, status: 200
      else
        render json: revocation_error_response, status: :forbidden
      end
    end

    def introspect
      introspection = OAuth::TokenIntrospection.new(server, token)

      if introspection.authorized?
        render json: introspection.to_json, status: 200
      else
        error = introspection.error_response
        headers.merge!(error.headers)
        render json: error.body, status: error.status
      end
    end

    private

    # OAuth 2.0 Section 2.1 defines two client types, "public" & "confidential".
    # A malicious client may attempt to guess valid tokens on this endpoint
    # by making revocation requests against potential token strings.
    # According to this specification, a client's request must contain a
    # valid client_id, in the case of a public client, or valid client
    # credentials, in the case of a confidential client. The token being
    # revoked must also belong to the requesting client.
    #
    # Once a confidential client is authenticated, it must be authorized to
    # revoke the provided access or refresh token. This ensures one client
    # cannot revoke another's tokens.
    #
    # Doorkeeper determines the client type implicitly via the presence of the
    # OAuth client associated with a given access or refresh token. Since public
    # clients authenticate the resource owner via "password" or "implicit" grant
    # types, they set the application_id as null (since the claim cannot be
    # verified).
    #
    # https://tools.ietf.org/html/rfc6749#section-2.1
    # https://tools.ietf.org/html/rfc7009
    def authorized?
      # Token belongs to specific client, so we need to check if
      # authenticated client could access it.
      if token.application_id? && token.application.confidential?
        # We authorize client by checking token's application
        server.client && server.client.application == token.application
      else
        # Token was issued without client, authorization unnecessary
        true
      end
    end

    def revoke_token
      # The authorization server responds with HTTP status code 200 if the token
      # has been revoked successfully or if the client submitted an invalid
      # token
      token.revoke if token&.accessible?
    end

    # Doorkeeper does not use the token_type_hint logic described in the
    # RFC 7009 due to the refresh token implementation that is a field in
    # the access token model.
    def token
      @token ||= Doorkeeper.config.access_token_model.by_token(params["token"]) ||
                 Doorkeeper.config.access_token_model.by_refresh_token(params["token"])
    end

    def strategy
      @strategy ||= server.token_request(params[:grant_type])
    end

    def authorize_response
      @authorize_response ||= begin
        before_successful_authorization
        auth = strategy.authorize
        after_successful_authorization unless auth.is_a?(Doorkeeper::OAuth::ErrorResponse)
        auth
      end
    end

    def after_successful_authorization
      Doorkeeper.config.after_successful_authorization.call(self)
    end

    def before_successful_authorization
      Doorkeeper.config.before_successful_authorization.call(self)
    end

    def revocation_error_response
      error_description = I18n.t(:unauthorized, scope: %i[doorkeeper errors messages revoke])

      { error: :unauthorized_client, error_description: error_description }
    end



  end
end