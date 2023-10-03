# frozen_string_literal: true

require "htmlbeautifier"

module InspectHTMLCapybara
  def inspect_html(node = page)
    puts HtmlBeautifier.beautify(node.native.inner_html)
  end
end

module InspectHTMLResponse
  def inspect_html(html = response.body)
    puts HtmlBeautifier.beautify(html)
  end
end

RSpec.configure do |config|
  config.include InspectHTMLCapybara, type: :system
  config.include InspectHTMLCapybara, type: :component
  config.include InspectHTMLResponse, type: :request
end
