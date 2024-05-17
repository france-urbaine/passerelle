# frozen_string_literal: true

# See https://actionpolicy.evilmartians.io to configure ActionPolicy
# Example:
#
# Rails.application.configure do
#   config.action_policy.cache_store = Rails.cache
# end

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
