# frozen_string_literal: true

ActiveSupport::Notifications.subscribe("action_policy.apply_rule") do |*args|
  Rails.logger.debug do
    event  = ActiveSupport::Notifications::Event.new(*args)
    result = event.payload[:value] ? "granted" : "denied"
    policy = event.payload[:policy]
    rule   = event.payload[:rule]
    cached = event.payload[:cached] ? "hit" : "missed"

    "  \e[1m[ActionPolicy]\e[0m Apply #{result} for #{policy}##{rule} (cache #{cached})"
  end
end

ActiveSupport::Notifications.subscribe("action_policy.authorize") do |*args|
  Rails.logger.debug do
    event  = ActiveSupport::Notifications::Event.new(*args)
    result = event.payload[:value] ? "granted" : "denied"
    policy = event.payload[:policy]
    rule   = event.payload[:rule]
    cached = event.payload[:cached] ? "hit" : "missed"

    "  \e[1m[ActionPolicy]\e[0m Authorize #{result} for #{policy}##{rule} (cache #{cached})"
  end
end

ActiveSupport::Notifications.subscribe("render.view_component") do |*args|
  Rails.logger.debug do
    event     = ActiveSupport::Notifications::Event.new(*args)
    component = event.payload[:name]

    "  \e[1m[ViewComponent]\e[0m Render #{component}"
  end
end

ActiveSupport::Notifications.subscribe("rack.attack") do |*args|
  Rails.logger.info do
    event  = ActiveSupport::Notifications::Event.new(*args)
    type   = event.payload[:request].env["rack.attack.matched"]
    method = event.payload[:request].request_method
    path   = event.payload[:request].fullpath
    ip     = event.payload[:request].remote_ip

    "Rack Attack: #{type} after #{method} #{path} from #{ip}"
  end
end
