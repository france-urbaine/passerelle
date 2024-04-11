# frozen_string_literal: true

module Matchers
  module HaveContentType
    extend RSpec::Matchers::DSL

    matcher :have_content_type do |expected|
      match do |actual|
        unless actual.is_a?(ActionDispatch::TestResponse)
          raise TypeError, "Expect actual to be a response, instead got #{actual.class.name}"
        end

        @actual = actual.content_type
        Mime.fetch(expected) == @actual
      end
    end

    matcher :have_media_type do |expected|
      match do |actual|
        unless actual.is_a?(ActionDispatch::TestResponse)
          raise TypeError, "Expect actual to be a response, instead got #{actual.class.name}"
        end

        @actual = actual.media_type
        Mime.fetch(expected) == @actual
      end
    end
  end
end
