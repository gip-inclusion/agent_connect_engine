require_relative "lib/agent_connect/version"

Gem::Specification.new do |spec|
  spec.name        = "agent_connect"
  spec.version     = AgentConnect::VERSION
  spec.authors     = ["Michaël Villeneuve"]
  spec.email       = ["mvilleneuve.pro@gmail.com"]
  spec.license     = "MIT"
  spec.summary     = "Agent Connect client for Ruby on Rails"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8.4"
  spec.add_dependency "typhoeus", ">= 1.4.0"
  spec.add_dependency "openid_connect", ">= 2"
  spec.add_dependency "jwt", "2.7.1"
end
