# frozen_string_literal: true

module RequestTestHelpers
  module InspectHTML
    extend ActiveSupport::Concern

    included do
      require "htmlbeautifier"
    end

    def inspect_html(html = response.body)
      puts HtmlBeautifier.beautify(html)
    end
  end
end
