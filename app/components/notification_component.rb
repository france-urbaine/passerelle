# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
  attr_reader :type, :data

  def initialize(type, data)
    @type = type
    @data = data
  end

  def title
    data.is_a?(Hash) ? data[:title] : data
  end

  def description
    data[:description] if data.is_a?(Hash)
  end
end
