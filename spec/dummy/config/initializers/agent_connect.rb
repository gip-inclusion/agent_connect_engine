AgentConnect.initialize! do |config|
  config.client_id = "client_id"
  config.client_secret = "client_secret"
  config.base_url = "https://fca.integ01.dev-agentconnect.fr/api/v2"
  config.scope = "openid email given_name usual_name"
  config.algorithm = "RS256"
end
