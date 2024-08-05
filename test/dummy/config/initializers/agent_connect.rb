AgentConnect.initialize! do |config|
  config.client_id = "client_id"
  config.client_secret = "client_secret"
  config.base_url = "https://base_url"

  config.callback = ->(user_info) do
    p user_info
  end
end
