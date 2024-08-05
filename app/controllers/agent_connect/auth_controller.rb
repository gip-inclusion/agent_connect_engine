module AgentConnect
  class AuthController < ApplicationController
    def auth
      auth_client = AgentConnect::Client::Auth.new(login_hint: params[:login_hint])
      session[:agent_connect_state] = auth_client.state
      session[:nonce] = auth_client.nonce

      redirect_to auth_client.redirect_url(callback_url), allow_other_host: true
    end

    def callback
      callback_client = AgentConnectOpenIdClient::Callback.new(
        session_state: session.delete(:agent_connect_state),
        params_state: params[:state],
        callback_url: callback_url,
        nonce: session.delete(:nonce)
      )

      unless callback_client.fetch_user_info_from_code!(params[:code])
        flash[:error] = generic_error_message
        redirect_to(new_agent_session_path) and return
      end

      AgentConnect.callback.call(callback_client, self)
    end

    private

    def generic_error_message
      support_email = current_domain.support_email
      %(Nous n'avons pas pu vous authentifier. Contactez le support à l'adresse <a href="mailto:#{support_email}">#{support_email}</a> si le problème persiste.)
    end
  end
end