# frozen_string_literal: true

module Matchers
  module HaveBody
    extend RSpec::Matchers::DSL

    matcher :have_empty_body do
      match do |actual|
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::TestResponse)

        @actual = actual.body
        @actual.blank?
      end

      failure_message do
        "expected response to #{description} but is was #{@actual.inspect}"
      end
    end

    matcher :have_body do
      include ChainableBodyMatcher

      match do |actual|
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::TestResponse)

        @actual = actual.body
        @actual.present? &&
          chainable_body_matcher_matches?(@actual)
      end
    end

    matcher :have_json_body do
      include ChainableBodyMatcher

      match do |actual|
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::TestResponse)

        @actual = actual.parsed_body

        parsed_body_as_json?(@actual) &&
          chainable_body_matcher_matches?(@actual)
      end

      def parsed_body_as_json?(actual)
        actual.is_a?(Array) || actual.is_a?(Hash)
      end
    end

    matcher :have_html_body do
      include ChainableBodyMatcher

      chain :with_turbo_frame do |frame|
        @expected_turbo_frame = frame
      end

      match do |actual|
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::TestResponse)

        @actual = actual.parsed_body

        parsed_body_as_html?(@actual) &&
          chainable_body_matcher_matches?(@actual) &&
          expected_turbo_frame_matches?(@actual)
      end

      def parsed_body_as_html?(actual)
        actual.is_a?(Nokogiri::HTML5::Document)
      end

      def expected_turbo_frame_matches?(actual)
        @expected_turbo_frame.nil? || actual.at("turbo-frame##{@expected_turbo_frame}").present?
      end
    end

    module ChainableBodyMatcher
      extend ActiveSupport::Concern

      included do
        chain :to,     :other_matcher
        chain :not_to, :other_negative_matcher

        failure_message do
          message  = "expected to #{description}"
          message += "\n#{other_matcher&.failure_message}" if other_matcher
          message += "\n#{other_negative_matcher&.failure_message_when_negated}" if other_negative_matcher
          message
        end
      end

      def chainable_body_matcher_matches?(actual)
        other_matcher_matches?(actual) && other_negative_matcher_matches?(actual)
      end

      def other_matcher_matches?(actual)
        other_matcher.nil? || other_matcher.matches?(actual)
      end

      def other_negative_matcher_matches?(actual)
        other_negative_matcher.nil? || other_negative_matcher.does_not_match?(actual)
      end
    end
  end
end
