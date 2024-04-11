# frozen_string_literal: true

require "htmlbeautifier"

module InspectHTMLHelpers
  def inspect_html(html)
    puts HtmlBeautifier.beautify(html)
  end
end

RSpec.configure do |config|
  config.include Matchers::HaveHTMLAttribute, type: :helper
  config.include InspectHTMLHelpers,          type: :helper
end
