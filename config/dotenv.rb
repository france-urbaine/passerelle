# frozen_string_literal: true

# Manually load .env files instead of using dotenv-rails.
#
#   1 - allow to pass a DOTENV env variable
#
#     Example: `DOTENV=production rails c`
#
#     It loads to an environment with developement capacities,
#     but connected to production databases & services
#
#   2 - output the current set of selected variables
#
begin
  require "dotenv"
  require "pathname"
rescue LoadError
  return
end

default_env = "development"
default_env = "test" if ENV["RAILS_ENV"] == "test"

env = ENV.fetch("DOTENV", default_env)

def log(message)
  puts "\e[34m[ config/dotenv ]\e[0m #{message}" unless ENV["DOTENV_QUIET"]
end

log "Loading #{env} environment variables"

[
  ".env.#{env}.local",
  (".env.local" unless env == "test"),
  ".env.#{env}",
  ".env"
].each do |path|
  next unless path

  path = Pathname.pwd.join(path)
  next unless path.exist?

  log " - load #{path}"
  Dotenv.load(path)
end
