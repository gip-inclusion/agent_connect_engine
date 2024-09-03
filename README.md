# AgentConnect

[![Build](https://github.com/gip-inclusion/agent_connect_engine/actions/workflows/main.yml/badge.svg)](https://github.com/gip-inclusion/agent_connect_engine/actions)

Cette gem est un engine Rails permettant de simplifier l'intégration d'AgentConnect dans une application Rails.

## Installation
Ajouter cette ligne dans votre Gemfile :

```ruby
gem "agent_connect"
```

And then execute:
```bash
$ bundle
```

## Usage

### Configuration
Pour pouvoir intégrer AgentConnect dans votre application, vous devez configurer l'engine, pour cela créez un fichier `config/initializers/agent_connect.rb` et ajoutez le code suivant :
```ruby
AgentConnect.initialize! do |config|
  # Ces informations vous seront fournies par l'équipe AgentConnect après avoir rempli le formulaire démarches simplifiées
  config.client_id = ENV["AGENT_CONNECT_CLIENT_ID"]
  config.client_secret = ENV["AGENT_CONNECT_CLIENT_SECRET"]
  config.base_url = ENV["AGENT_CONNECT_BASE_URL"]

  # Ceci détermine les informations que vous souhaitez récupérer de l'usager, vous devez au préalable avec coché ces informations dans le formulaire démarches simplifiées
  config.scope = "openid email"

  # Ceci correspond à l'algorithme de chiffrement spécificé via le formulaire démarches simplifiées
  config.algorithm = ENV["AGENT_CONNECT_ALGORITHM"]
end
```

### Routes
Ajoutez les routes de l'engine dans votre fichier `config/routes.rb` :
```ruby
Rails.application.routes.draw do
  agent_connect(controller: MyAgentConnectController, path: "/agent_connect")
end
```

Ces routes déterminent ce que vous devrez fournir à AgentConnect via le formulaire démarches simplifiées.
Par défaut voici les routes qui seront ajoutées avec le code ci-dessus : 
```
GET /agent_connect/auth
GET /agent_connect/callback
```

Si votre site est par exemple rdv-insertion.fr, vous devrez renseigner dans le formulaire démarches simplifiées l'url suivante :
```
https://rdv-insertion.fr/agent_connect/callback
```

### Ajout du bouton de connexion
Ajoutez le bouton de connexion AgentConnect dans votre vue de connexion :
```erb
<%= render 'agent_connect/connect_button' %>
```
Ce bouton redirigera l'usager vers la page de connexion AgentConnect. En retour de cette connexion, l'usager sera redirigé vers la route `callback` de votre controller ci-dessous.

### Controller
Créez un controller pour gérer la connexion AgentConnect :
```ruby
class MyAgentConnectController < AgentConnect::BaseController
  def callback
    # Cette méthode sera appelée en cas de succès ou d'échec de la connexion AgentConnect
    # suite à un clic sur le bouton de connexion AgentConnect.
    # Pour vérifier cela et récuperer les informations de l'usager vous aurez accès à l'objet `authentification`

    if authentification.success?
      # L'usager s'est connecté avec succès à AgentConnect
      # Dans ce cas vous pourriez vouloir rechercher l'usager dans votre base de données et le connecter en faisant par exemple :
      agent = Agent.find_or_create_by!(email: authentification.user_email)
      session[:agent_id] = agent.id

      # Pour pouvoir gérer la déconnexion de l'usager, vous pouvez stocker le token de l'usager dans la session
      # Vous devrez utiliser ce token pour déconnecter l'usager de AgentConnect
      session[:agent_connect_token] = authentification.id_token_for_logout

      # Puis rediriger l'usager vers la page de votre choix
      redirect_to root_path
    else
      # L'usager n'a pas pu se connecter à AgentConnect.
      # Dans ce cas vous pourriez vouloir rediriger l'usager vers la page de connexion avec un message d'erreur.
    end
  end
end
```

### Déconnexion
Lorsqu'un usager est connecté à votre application et souhaite se déconnecter, vous pouvez le déconnecter de AgentConnect en utilisant le token que vous pouvez stocker préalablement en session, par exemple si vous avez un controller `SessionsController` :
```ruby
class SessionsController < ApplicationController
  def destroy
    # Récupérez l'url de déconnexion de l'usager en lui passant le token stocké en session
    logout_service = AgentConnect::Client::Logout.new(session[:agent_connect_token])
    # Vous pouvez aussi passer une url de redirection après la déconnexion
    disconnect_url = logout_service.agent_connect_logout_url(root_url)

    # Déconnexion de l'usager de votre application
    session[:agent_id] = nil
    session[:agent_connect_token] = nil

    # Redirection de l'usager vers la page de déconnexion AgentConnect
    redirect_to disconnect_url, allow_other_host: true
  end
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
