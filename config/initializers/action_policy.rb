# frozen_string_literal: true

# See https://actionpolicy.evilmartians.io to configure ActionPolicy
# Example:
#
Rails.application.configure do
  config.action_policy.cache_store = Rails.cache
end

# Add INSTRUMENT_ACTION_POLICY=true to your .env file to get log more
# details about policies
#
if ENV.fetch("INSTRUMENT_ACTION_POLICY", "false") == "true"
  ActiveSupport::Notifications.subscribe("action_policy.apply_rule") do |*args|
    Rails.logger.debug do
      event  = ActiveSupport::Notifications::Event.new(*args)
      result = event.payload[:value] ? "granted" : "denied"
      policy = event.payload[:policy]
      rule   = event.payload[:rule]
      cached = event.payload[:cached] ? "hit" : "missed"

      if result == "denied"
        reasons = event.payload[:result].reasons.details || {}
        details = " (reasons: #{reasons})"
      end

      "  \e[1m[ActionPolicy]\e[0m Apply #{result} for #{policy}##{rule}#{details} (cache #{cached})"
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
end
