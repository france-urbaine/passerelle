# frozen_string_literal: true

module InspectHTML
  module TestHelper
    extend ActiveSupport::Concern

    included do
      require "htmlbeautifier"
    end

    def inspect_html(node)
      html =
        case node
        when Capybara::Session         then node.source
        when Capybara::Node::Simple    then node.native.to_s
        when Capybara::Node::Base      then node.native["outerHTML"]
        when Nokogiri::XML::Document   then node.to_s # HTML5::Document & HTML4::Document inherit from XML::Document
        when String                    then node
        else
          raise TypeError, "unexpected argument: #{node.inspect}"
        end

      # rubocop:disable RSpec/Output
      # The whole point of this helper is to output to stdout.
      #
      puts HtmlBeautifier.beautify(html)
      #
      # rubocop:enable RSpec/Output
    end
  end

  module CapybaraTestHelper
    include TestHelper

    def inspect_html(node = page)
      super
    end
  end

  module ViewTestHelper
    include TestHelper

    def inspect_html(node = rendered)
      super
    end
  end

  module RequestTestHelper
    include TestHelper

    def inspect_html(node = response.body)
      super
    end
  end
end
