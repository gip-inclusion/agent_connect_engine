Rails.application.routes.draw do
  mount AgentConnect::Engine => "/agent_connect"
end
