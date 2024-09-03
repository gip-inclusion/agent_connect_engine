module AgentConnect
  module Concerns
    module Auth
      extend ActiveSupport::Concern

      included do
        attr_reader :authentication

        before_action :set_agent_connect_client, only: [:callback]
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

      private

      def set_agent_connect_client
        @authentication = AgentConnect::Client::Callback.new(
          session_state: session.delete(:agent_connect_state),
          params_state: params[:state],
          callback_url: agent_connect_callback_url,
          nonce: session.delete(:nonce)
        )

        authentication.fetch_user_info_from_code!(params[:code])
      rescue => e
        Rails.logger.error(e)
      end
    end
  end
end