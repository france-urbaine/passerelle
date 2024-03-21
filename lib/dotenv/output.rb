# frozen_string_literal: true

# rubocop:disable Rails/Output
# Calling puts is what we try to achieve here:
# It outputs the files loaded by Dotenv
#
ActiveSupport::Notifications.subscribe("load.dotenv") do |*args|
  event    = ActiveSupport::Notifications::Event.new(*args)
  env      = event.payload[:env]
  filename = Pathname.new(env.filename).relative_path_from(Dotenv::Rails.root.to_s).to_s

  puts "[dotenv] Load \e[33m#{filename}\e[0m" unless ENV["DOTENV_OUTPUT"] == "false"
end
#
# rubocop:enable Rails/Output
