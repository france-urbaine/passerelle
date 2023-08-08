# frozen_string_literal: true

if defined?(Rack::MiniProfiler)
  # See https://github.com/MiniProfiler/rack-mini-profiler#configuration
  # for more configuration options

  Rack::MiniProfiler.config.position = "bottom-right"
end
