# frozen_string_literal: true

module UI
  class NotificationComponent < ApplicationViewComponent
    define_component_helper :notification_component

    attr_reader :data, :actions

    def initialize(data, actions = nil)
      @data    = parse_data(data)
      @actions = parse_actions(actions)
      super()
    end

    def parse_data(data)
      case data
      when Hash   then data.stringify_keys
      when String then { "title" => data }
      else {}
      end
    end

    def parse_actions(actions)
      Array.wrap(actions).map do |action|
        action = action.symbolize_keys

        UI::ButtonComponent.new(
          action[:label],
          action[:url],
          method: action[:method],
          params: action[:params]
        )
      end
    end

    def title
      data["title"]
    end

    def type
      data.fetch("type", "info")
    end

    def delay
      data["delay"]
    end

    def description
      data["description"]
    end
  end
end
