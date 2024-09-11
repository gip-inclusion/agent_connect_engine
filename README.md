# AgentConnect

[![Build](https://github.com/gip-inclusion/agent_connect_engine/actions/workflows/main.yml/badge.svg)](https://github.com/gip-inclusion/agent_connect_engine/actions)

Cette gem est un engine Rails permettant de simplifier l'intégration d'AgentConnect dans une application Rails.

![bouton agent connect](https://github.com/gip-inclusion/agent_connect_engine/blob/feat/improved-api/docs/bouton-connexion.png?raw=true)

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

  # Ceci détermine les informations que vous souhaitez récupérer de l'usager, vous devez au préalable avoir coché ces informations dans le formulaire démarches simplifiées
  config.scope = "openid email"

  # Ceci correspond à l'algorithme de chiffrement spécifié via le formulaire démarches simplifiées
  config.algorithm = ENV["AGENT_CONNECT_ALGORITHM"]
end
```

### Routes
Ajoutez les routes de l'engine dans votre fichier `config/routes.rb` :
```ruby
Rails.application.routes.draw do
  # Vous devrez évidemment créer le controller spécifié ci-dessous
  agent_connect(controller: MyAgentConnectController, path: "/agent_connect")
end
```

En ajoutant cette ligne dans votre fichier de routes, vous définissez les routes qui seront utilisées pour la connexion AgentConnect. Par défaut, les routes suivantes seront créées :
```
GET /agent_connect/auth 
=> Cette route permet de rediriger l'usager vers la page de connexion AgentConnect, c'est celle qui sera appelée lors du clic sur le bouton de connexion AgentConnect

GET /agent_connect/callback
=> Cette route est celle qui sera appelée par AgentConnect après la connexion de l'usager, elle permettra de récupérer les informations de l'usager et de le connecter à votre application

GET /agent_connect/logout
=> Cette route permet de déconnecter l'usager de votre application et de le rediriger vers la page de déconnexion AgentConnect
```

Lorsque vous remplirez le formulaire démarches simplifiées, vous devrez renseigner l'url de la route `callback` de votre application dans le champ `URLs de redirection de connexion (Internet) :`.

Si votre site est par exemple rdv-insertion.fr, vous devrez renseigner dans le formulaire démarches simplifiées l'url suivante :
```
https://rdv-insertion.fr/agent_connect/callback
```

![résultat formulaire](https://github.com/gip-inclusion/agent_connect_engine/blob/feat/improved-api/docs/configuration-demarche-simplifiees.png?raw=true)



### Ajout du bouton de connexion
Ajoutez le bouton de connexion AgentConnect dans votre vue de connexion :
```erb
<%= render 'agent_connect/connect_button' %>
```
Ce bouton redirigera l'usager vers la page de connexion AgentConnect. En retour de cette connexion, l'usager sera redirigé vers la route `callback` de votre controller ci-dessous.

### Controller
Créez un controller pour gérer la connexion AgentConnect :
```ruby
# Ce controller doit correspondre à celui que vous avez spécifié dans le fichier de routes
class MyAgentConnectController < ApplicationController
  # Vous devrez ensuite définir la méthode suivante :
  def callback
    # Cette méthode sera appelée quand une personne redirigée vers AgentConnect aura rempli le formulaire de connexion sur le site d'AgentConnect.
    # Elle est chargée d'authentifier cette personne.

    if authentification.success?
      # L'usager s'est connecté avec succès à AgentConnect.
      # Dans ce cas vous pourriez vouloir rechercher l'usager dans votre base de données et le connecter en faisant par exemple :
      agent = Agent.find_or_create_by!(email: authentification.user_email)
      session[:agent_id] = agent.id

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
Lorsqu'un usager est connecté à votre application et souhaite se déconnecter, vous pouvez le déconnecter d'AgentConnect en redirigeant l'usager vers la route de déconnexion AgentConnect. 

Par exemple dans votre fichier de vue de déconnexion :
```ruby
<%= link_to "Se déconnecter", agent_connect_logout_path %>
```

Ce lien redirigera l'usager vers la page de déconnexion AgentConnect. En retour de cette déconnexion, l'usager sera redirigé vers l'URL de déconnexion spécifiée dans le formulaire démarches simplifiées.

Si vous souhaitez effectuer des actions supplémentaires lors de la déconnexion de l'usager, vous pouvez redéfinir la méthode `logout` dans votre controller AgentConnect, ou simplement ajouter un callback à la méthode `logout` de l'engine.

Par exemple sur rdv-insertion nous avons le code suivant qui permet de vider la session de l'usager lorsqu'il se déconnecte :
```ruby
class MyAgentConnectController < ApplicationController
  after_action(only: :logout) { clear_session } # Cette ligne permet de vider la session de l'usager après qu'il se soit déconnecté

  def callback
    # ...
  end
end
```


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
