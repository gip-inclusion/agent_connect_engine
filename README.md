# AgentConnect
Cette Gem est un engine permet de faciliter l'implémentation d'AgentConnect dans un projet Rails.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "agent_connect"
```

And then execute:
```bash
$ bundle
```

## Usage

### Configuration
First you need to configure this gem with your AgentConnect credentials.
```ruby
AgentConnect.initialize! do |config|
  # Declare your client_id, client_secret and the base_url of the AgentConnect API
  config.client_id = ENV["AGENT_CONNECT_CLIENT_ID"]
  config.client_secret = ENV["AGENT_CONNECT_CLIENT_SECRET"]
  config.base_url = ENV["AGENT_CONNECT_BASE_URL"]

  # Declare the callback that will be called after the user is authenticated
  # The callback is executed in the scope of a controller so you can redirect the user
  # after a successful authentication
  config.callback = ->(user_info, controller) do
    # Connect the user to your application
    # For instance :
    agent = Agent.find_by(email: user_info["email"])
    if agent
      controller.session[:agent_id] = agent.id
      controller.redirect_to root_path
    else
      controller.redirect_to new_agent_path
    end
  end
end
```

### Routes
Mount the engine in your routes file in order to expose the callback and auth routes.
```ruby
Rails.application.routes.draw do
  mount AgentConnect::Engine => "/agent_connect"
end
```

### Connect button
Add the AgentConnect button to your login page.
```erb
<%= render 'agent_connect/connect_button' %>
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
