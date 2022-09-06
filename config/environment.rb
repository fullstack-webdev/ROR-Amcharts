# Load the rails application
require File.expand_path('../application', __FILE__)

# Load heroku vars from local file
heroku_env = File.join(Rails.root, 'config', 'heroku_env.rb')
load(heroku_env) if File.exists?(heroku_env)

# Initialize the rails application
ElephantWebApp::Application.initialize!


# Speed up tests by lowering BCrypt's cost function.
require 'bcrypt'
silence_warnings do
    BCrypt::Engine::DEFAULT_COST = BCrypt::Engine::MIN_COST
end