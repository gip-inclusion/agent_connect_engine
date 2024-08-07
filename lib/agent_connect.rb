require "agent_connect/version"
require "agent_connect/engine"
require "openid_connect"

module AgentConnect
  mattr_accessor :client_id, :client_secret, :scope, :base_url, :success_callback, :error_callback, :discovery, :algorithm,
                  :bootstrap_error_callback

  class << self
    def initialize!
      yield(self)

      begin
        self.discovery = OpenIDConnect::Discovery::Provider::Config.discover!(base_url)
      rescue StandardError => e
        raise e unless bootstrap_error_callback.present?

        bootstrap_error_callback.call(e)
      end
    end
  end
end
