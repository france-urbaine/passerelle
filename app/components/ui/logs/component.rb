# frozen_string_literal: true

module UI
  module Logs
    class Component < ApplicationViewComponent
      define_component_helper :logs_component

      renders_many :logs, "Log"

      DEFAULT_TIME_ZONE   = "UTC"
      DEFAULT_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%L%:z" # ISO 8601 by default

      def initialize(time_zone: DEFAULT_TIME_ZONE, time_format: DEFAULT_TIME_FORMAT)
        @time_zone   = time_zone
        @time_format = time_format
        super()
      end

      def call
        log_message = logs.map do |log|
          helpers.sanitize("#{format_time(log.time)} - #{log.text}\n")
        end

        tag.pre(class: "logs") do
          concat "\n"
          safe_join log_message
        end
      end

      def format_time(time)
        time.in_time_zone(@time_zone).strftime(@time_format)
      end

      class Log < ApplicationViewComponent
        attr_reader :time, :text

        def initialize(time, text)
          @time = time
          @text = text
          super()
        end

        def call
          @text
        end
      end
    end
  end
end
