# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
  attr_reader :data

  def initialize(data)
    case data
    when Hash   then @data = data.stringify_keys
    when String then @data = { "title" => data }
    else
      raise TypeError, "unexpected argument: #{data.inspect}"
    end
    super()
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

  def actions
    @actions ||= Array.wrap(data["actions"]).map(&:symbolize_keys)
  end
end
