AgentConnect::Engine.routes.draw do
  get :auth, to: 'auth#auth'
  get :callback, to: 'auth#callback'
end
