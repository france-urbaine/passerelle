# frozen_string_literal: true

module RoutingSpecHelpers
  def default_routes_options(**options)
    @default_routes_options = options
  end

  def clear_default_routes_options
    @default_routes_options = {}
  end

  def route_to(*, **)
    super(*, **(@default_routes_options || {}), **)
  end
end

RSpec.configure do |config|
  config.include RoutingSpecHelpers, type: :routing

  # Avoid adding `subdomain: ""` to most of the routing specs
  #
  config.before type: :routing do
    default_routes_options subdomain: ""
  end

  config.before type: :routing, api: true do
    default_routes_options subdomain: "api"
  end
end
