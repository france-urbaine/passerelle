# frozen_string_literal: true

module SafeLocationParam
  extend ActiveSupport::Concern

  def safe_location_param(key, default = nil)
    location = params[key]

    # https://rubular.com/r/N81eAtqtkavdMb
    raise "unexpected location: #{location}" if location && !location.match?(%r{^/[a-z]})

    location || default
  end
end
