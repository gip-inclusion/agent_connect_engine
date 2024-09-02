require "agent_connect/routes"

module AgentConnect
  class Engine < ::Rails::Engine
    isolate_namespace AgentConnect

    initializer 'agent_connect.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        append_view_path AgentConnect::Engine.root.join('app', 'views')
      end
    end
  end
end
