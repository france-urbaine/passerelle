# frozen_string_literal: true

require "htmlbeautifier"

module InspectHTMLCapybara
  def inspect_html(node = page)
    html =
      case node
      when Capybara::Session      then node.html
      when Capybara::Node::Simple then node.native.inner_html
      when Capybara::Node::Base   then node.native["innerHTML"]
      end

    puts HtmlBeautifier.beautify(html)
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
