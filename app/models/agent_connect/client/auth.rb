# see https://github.com/numerique-gouv/agentconnect-documentation/blob/main/doc_fs/implementation_technique.md
module AgentConnect
  module Client
    class Auth
      attr_reader :state, :nonce

      def initialize(login_hint: nil, force_login: false)
        @login_hint = login_hint
        @force_login = force_login
        @state = "agent_connect_state_#{SecureRandom.base58(32)}"
        @nonce = "agent_connect_nonce_#{SecureRandom.base58(32)}"
      end

      def redirect_url(callback_url)
        query_params = {
          response_type: "code",
          client_id: AgentConnect.client_id,
          redirect_uri: callback_url,
          scope: "openid email given_name usual_name",
          state: state,
          nonce: nonce,
          acr_values: "eidas1",
          login_hint: @login_hint,
          prompt: @force_login ? "login" : nil,
        }.compact_blank

        "#{AgentConnect.base_url}/authorize?#{query_params.to_query}"
      end
    end
  end
end
