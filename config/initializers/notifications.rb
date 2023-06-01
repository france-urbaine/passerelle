# frozen_string_literal: true

ActiveSupport::Notifications.subscribe("action_policy.apply_rule") do |_, _, _, _, data|
  Rails.logger.debug do
    result = data[:value] ? "granted" : "denied"
    policy = data[:policy]
    rule   = data[:rule]
    cached = data[:cached] ? "hit" : "miss"

    "  [ActionPolicy] Apply #{result} for #{policy}##{rule} #{cached} cache"
  end
end

ActiveSupport::Notifications.subscribe("action_policy.authorize") do |_, _, _, _, data|
  Rails.logger.debug do
    result = data[:value] ? "granted" : "denied"
    policy = data[:policy]
    rule   = data[:rule]
    cached = data[:cached] ? "hit" : "miss"

    "  [ActionPolicy] Authorize #{result} for #{policy}##{rule} #{cached} cache"
  end
end

ActiveSupport::Notifications.subscribe("rack.attack") do |_, _, _, _, data|
  Rails.logger.info do
    type   = data[:request].env["rack.attack.matched"]
    method = data[:request].request_method
    path   = data[:request].fullpath
    ip     = data[:request].remote_ip

    "Rack Attack: #{type} after #{method} #{path} from #{ip}"
  end
end
