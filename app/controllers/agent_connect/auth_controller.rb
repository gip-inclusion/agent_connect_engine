module AgentConnect
  class AuthController < ActionController::Base
    def auth
      auth_client = AgentConnect::Client::Auth.new(login_hint: params[:login_hint])
      session[:agent_connect_state] = auth_client.state
      session[:nonce] = auth_client.nonce

      redirect_to auth_client.redirect_url(callback_url), allow_other_host: true
    end

    def callback
      callback_client = AgentConnect::Client::Callback.new(
        session_state: session.delete(:agent_connect_state),
        params_state: params[:state],
        callback_url: callback_url,
        nonce: session.delete(:nonce)
      )

      unless callback_client.fetch_user_info_from_code!(params[:code])
        instance_exec(callback_client, &AgentConnect.error_callback)
        return
      end

      instance_exec(callback_client, &AgentConnect.success_callback)
    rescue => e
      instance_exec(callback_client, &AgentConnect.error_callback)
    end
  end
end