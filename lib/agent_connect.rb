require "agent_connect/version"
require "agent_connect/engine"
require "openid_connect"

module AgentConnect
  mattr_accessor :client_id, :base_url, :client_secret, :end_session_endpoint, :issuer, :jwks_uri,
                  :authorization_endpoint, :token_endpoint, :userinfo_endpoint, :end_session_endpoint,
                  :success_callback, :error_callback

  class << self
    def initialize!
      yield(self)
      OpenIDConnect::Discovery::Provider::Config.discover!(base_url)
    end
  end
end
