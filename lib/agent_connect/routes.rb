module ActionDispatch::Routing
  class Mapper
    def agent_connect(controller:, path: "/agent_connect")
      controller.class_eval do
        include AgentConnect::Concerns::Auth
      end

      scope path, controller: controller.name.underscore.split('_').first, as: "agent_connect" do
        get "auth"
        get "callback"
      end
    end
  end
end
