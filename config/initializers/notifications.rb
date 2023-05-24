# frozen_string_literal: true

ActiveSupport::Notifications.subscribe("action_policy.apply_rule") do |_, _, _, _, data|
  result = data[:value] ? "granted" : "denied"
  policy = data[:policy]
  rule   = data[:rule]
  cached = data[:cached] ? "hit" : "miss"

  Rails.logger.debug { "  [ActionPolicy] Apply #{result} for #{policy}##{rule} #{cached} cache" }
end

ActiveSupport::Notifications.subscribe("action_policy.authorize") do |_, _, _, _, data|
  result = data[:value] ? "granted" : "denied"
  policy = data[:policy]
  rule   = data[:rule]
  cached = data[:cached] ? "hit" : "miss"

  Rails.logger.debug { "  [ActionPolicy] Authorize #{result} for #{policy}##{rule} #{cached} cache" }
end
