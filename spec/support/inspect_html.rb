# frozen_string_literal: true

require "htmlbeautifier"

module InspectHTML
  def inspect_html(node = page)
    puts HtmlBeautifier.beautify(node.native.inner_html)
  end
end

RSpec.configure do |config|
  config.include InspectHTML, type: :system
  config.include InspectHTML, type: :component
end
