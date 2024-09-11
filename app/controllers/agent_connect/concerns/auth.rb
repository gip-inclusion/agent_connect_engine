module AgentConnect
  module Concerns
    module Auth
      extend ActiveSupport::Concern

      included do
        attr_reader :authentication

        before_action :set_agent_connect_client, only: [:callback]
        before_action :set_agent_connect_logout_client, only: [:logout]
      end

      def auth
        auth_client = AgentConnect::Client::Auth.new(login_hint: params[:login_hint])
        session[:agent_connect_state] = auth_client.state
        session[:nonce] = auth_client.nonce

        redirect_to auth_client.redirect_url(agent_connect_callback_url), allow_other_host: true
      end

      def callback
        raise NoMethodError, "You must implement the callback method in your controller"
      end

      def logout
        redirect_to authentication.agent_connect_logout_url(root_url), allow_other_host: true
      end

      private

      def set_agent_connect_logout_client
        @authentication = AgentConnect::Client::Logout.new(session[:agent_connect_id_token])
      end

      def set_agent_connect_client
        @authentication = AgentConnect::Client::Callback.new(
          session_state: session.delete(:agent_connect_state),
          params_state: params[:state],
          callback_url: agent_connect_callback_url,
          nonce: session.delete(:nonce)
        )

        authentication.fetch_user_info_from_code!(params[:code])
        session[:agent_connect_id_token] = authentication.id_token_for_logout
      rescue => e
        Rails.logger.error(e)
      end
    end
  end
end