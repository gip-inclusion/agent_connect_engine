# AgentConnect

[![Build](https://github.com/gip-inclusion/agent_connect_engine/actions/workflows/main.yml/badge.svg)](https://github.com/gip-inclusion/agent_connect_engine/actions)

This gem is a Rails engine simplyfing the integration of the AgentConnect in a Rails application.

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

  # This is optional, by default it will fallback to "HS256"
  config.algorithm = ENV["AGENT_CONNECT_ALGORITHM"]

  # Declare the callback that will be called after the user is authenticated
  # The callback is executed in the scope of a controller so you can redirect the user
  # after a successful authentication
  #
  # @param payload [Hash] the user information returned by the AgentConnect API
  config.success_callback = ->(payload) do
    # Connect the user to your application
    # For instance :
    agent = Agent.find_by(email: payload.user_email)
    if agent
      session[:agent_id] = agent.id
      redirect_to root_path
    else
      redirect_to new_agent_path
    end
  end

  config.error_callback = ->(error) do
    # Handle the error
    # For instance :
    flash[:error] = error
    redirect_to login_path
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
