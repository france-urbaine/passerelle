# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
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
    else raise TypeError, "unexpected argument: #{data.inspect}"
    end
  end

  def parse_actions(actions)
    Array.wrap(actions).map(&:symbolize_keys)
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
