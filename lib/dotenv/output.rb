# frozen_string_literal: true

# rubocop:disable Rails/Output
# Calling puts is what we try to achieve here:
# It outputs the files loaded by Dotenv
#
ActiveSupport::Notifications.subscribe("load.dotenv") do |*args|
  next if ENV["DOTENV_OUTPUT"] == "false"
  next if Rails.env.test? && ENV["CI_LESS_OUTPUT"] == "true" && ENV["DOTENV_OUTPUT"] != "true"

  event    = ActiveSupport::Notifications::Event.new(*args)
  env      = event.payload[:env]
  filename = Pathname.new(env.filename).relative_path_from(Dotenv::Rails.root.to_s).to_s

  puts "[dotenv] Load \e[33m#{filename}\e[0m"
end
#
# rubocop:enable Rails/Output
