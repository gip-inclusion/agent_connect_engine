require "agent_connect/version"
require "agent_connect/engine"
require "openid_connect"

module AgentConnect
  mattr_accessor :client_id, :client_secret, :scope, :base_url, :success_callback, :error_callback, :discovery, :algorithm

  class << self
    def initialize!
      yield(self)
      self.discovery = OpenIDConnect::Discovery::Provider::Config.discover!(base_url)
    end
  end
end
