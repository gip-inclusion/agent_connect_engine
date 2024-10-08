require "openid_connect"
# voir https://github.com/france-connect/Documentation-AgentConnect/blob/main/doc_fs/technique_fca/endpoints.md

module AgentConnect
  module Client
    class Callback
      class OpenIdFlowError < StandardError; end
      class ApiRequestError < StandardError; end

      def initialize(session_state:, params_state:, callback_url:, nonce:)
        @session_state = session_state
        @params_state = params_state
        @callback_url = callback_url
        @nonce = nonce
      end

      attr_reader :id_token_for_logout, :user_info

      def fetch_user_info_from_code!(code)
        validate_state!

        token = fetch_token(code, @callback_url)

        @user_info = fetch_user_info(token) || {}
      end

      def success?
        @user_info.present?
      end

      def user_email
        @user_info["email"]
      end

      def user_first_name
        # Agent Connect renvoie aussi le nom de famille après un espace
        @user_info["given_name"].gsub(/ #{@user_info['usual_name']}$/i, "")
      end

      def user_last_name
        @user_info["usual_name"]
      end

      private

      def validate_state!
        if @session_state.blank?
          raise OpenIdFlowError, "blank state in session"
        end

        unless ActiveSupport::SecurityUtils.secure_compare(@session_state, @params_state)
          Sentry.add_breadcrumb(Sentry::Breadcrumb.new(
                                  message: "Agent Connect states",
                                  data: {
                                    params: @params_state,
                                    session: @session_state,
                                  }
                                ))

          raise OpenIdFlowError, "State in session and params do not match"
        end
      end

      def fetch_token(code, agent_connect_callback_url)
        data = {
          client_id: AgentConnect.client_id,
          client_secret: AgentConnect.client_secret,
          code: code,
          grant_type: "authorization_code",
          redirect_uri: agent_connect_callback_url,
        }
        response = Typhoeus.post(
          URI("#{AgentConnect.base_url}/token"),
          body: data,
          headers: { "Content-Type" => "application/x-www-form-urlencoded" }
        )

        response_hash = JSON.parse(response.body)

        @id_token_for_logout = response_hash["id_token"]
        validate_nonce!(@id_token_for_logout)

        response_hash["access_token"]
      end

      def validate_nonce!(encoded_id_token)
        decoded_id_token = OpenIDConnect::ResponseObject::IdToken.decode(encoded_id_token, AgentConnect.discovery.jwks)
        decoded_id_token.verify!(
          issuer: AgentConnect.discovery.issuer,
          client_id: AgentConnect.client_id,
          nonce: @nonce
        )
      end

      def fetch_user_info(token)
        uri = URI("#{AgentConnect.base_url}/userinfo")
        uri.query = URI.encode_www_form({ schema: "openid" })

        response = Typhoeus.get(uri, headers: { "Authorization" => "Bearer #{token}" })

        return unless response.success?

        JWT.decode(response.body, nil, true, algorithms: AgentConnect.algorithm || AgentConnect.discovery.jwks.first["alg"], jwks: AgentConnect.discovery.jwks).first
      end
    end
  end
end