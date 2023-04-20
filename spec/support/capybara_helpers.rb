# frozen_string_literal: true

module CapybaraHelpers
  # Returns native html of the current element
  #
  def inspect_inner_html(element = page)
    element.native.inner_html
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :system
  config.include CapybaraHelpers, type: :component
end
