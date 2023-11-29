# frozen_string_literal: true

require "htmlbeautifier"

module InspectHTML
  def inspect_html(html)
    puts HtmlBeautifier.beautify(html)
  end
end

module InspectHTMLCapybara
  include InspectHTML

  def inspect_html(node = page)
    html =
      case node
      when Capybara::Session      then node.html
      when Capybara::Node::Simple then node.native.inner_html
      when Capybara::Node::Base   then node.native["innerHTML"]
      end

    super(html)
  end
end

module InspectHTMLResponse
  include InspectHTML

  def inspect_html(html = response.body)
    super(html)
  end
end

RSpec.configure do |config|
  config.include InspectHTMLCapybara, type: :system
  config.include InspectHTMLCapybara, type: :component
  config.include InspectHTMLResponse, type: :request
  config.include InspectHTML, type: :helper
end
