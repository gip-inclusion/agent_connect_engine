require_relative "../../app/controllers/agent_connect/concerns/auth"

module ActionDispatch::Routing
  class Mapper
    def agent_connect(controller:, path: "/agent_connect")
      controller.class_eval do
        include AgentConnect::Auth
      end

      scope path, controller: controller, as: "agent_connect" do
        get "auth", to: "auth#auth"
        get "callback", to: "auth#callback"
      end
    end
  end
end
