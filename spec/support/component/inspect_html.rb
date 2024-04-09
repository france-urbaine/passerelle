# frozen_string_literal: true

module ComponentTestHelpers
  module InspectHTML
    extend ActiveSupport::Concern

    included do
      require "htmlbeautifier"
    end

    def inspect_html(node = page)
      html =
        case node
        when Capybara::Node::Simple then node.native.inner_html
        when Capybara::Node::Base   then node.native["innerHTML"]
        end

      puts HtmlBeautifier.beautify(html)
    end
  end
end
