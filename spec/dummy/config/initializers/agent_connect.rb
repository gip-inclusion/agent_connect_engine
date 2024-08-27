AgentConnect.initialize! do |config|
  config.client_id = "client_id"
  config.client_secret = "client_secret"
  config.base_url = "https://fca.integ01.dev-agentconnect.fr/api/v2"
  config.scope = "openid email given_name usual_name"
  config.algorithm = "RS256"

  config.success_callback = ->(user_info) do
    redirect_to "/success_path"
    session[:agent] = {
      email: user_info.user_email,
      first_name: user_info.user_first_name,
      last_name: user_info.user_last_name,
    }
  end

  config.error_callback = ->(user_info) do
    redirect_to "/error_path"
  end
end
