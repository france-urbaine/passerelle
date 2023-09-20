# frozen_string_literal: true

module Matchers
  module HaveBody
    extend RSpec::Matchers::DSL

    matcher :have_empty_body do
      match do |actual|
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::TestResponse)

        actual.body.blank?
      end

      failure_message do
        "expected response to #{description} but is was #{actual.body.inspect}"
      end
    end

    matcher :have_body do
      include ChainableBodyMatcher
    end

    matcher :have_json_body do
      include ChainableBodyMatcher

      def actual_body(response)
        response.parsed_body
      end

      def actual_body_matches?(body)
        body.is_a?(Array) || body.is_a?(Hash)
      end
    end

    matcher :have_html_body do
      include ChainableBodyMatcher
      include ChainableTurboFrameMatcher

      def actual_body_matches?(body)
        body.present? &&
          body.match?(%r{\A(<!DOCTYPE[^>]+>)?\s*<html(.|\s)+<body(.|\s)+</body>\s*</html>\Z}) &&
          actual_body_include_expected_turbo_frame?(body)
      end
    end

    matcher :have_partial_html do
      include ChainableBodyMatcher
      include ChainableTurboFrameMatcher

      def actual_body_matches?(body)
        body.present? &&
          body.match?(/\A(?!<!DOCTYPE[^>]+>)?(?!<html)/) &&
          actual_body_include_expected_turbo_frame?(body)
      end
    end

    module ChainableBodyMatcher
      extend ActiveSupport::Concern

      included do
        chain :to, :other_matcher

        match do |actual|
          raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::TestResponse)

          @actual = actual_body(actual)
          actual_body_matches?(@actual) && (other_matcher.blank? || other_matcher.matches?(@actual))
        end

        failure_message do
          "expected to #{description}\n#{other_matcher&.failure_message}"
        end
      end

      def actual_body(response)
        response.body
      end

      def actual_body_matches?(body)
        body.present?
      end
    end

    module ChainableTurboFrameMatcher
      extend ActiveSupport::Concern

      included do
        chain :with_turbo_frame do |frame|
          @expected_turbo_frame = frame
        end
      end

      def actual_body_include_expected_turbo_frame?(body)
        return true if @expected_turbo_frame.nil?

        body.present? && body.match?(/<turbo-frame [^>]*id="#{@expected_turbo_frame}"/)
      end
    end
  end
end
