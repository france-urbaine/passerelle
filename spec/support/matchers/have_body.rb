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

    matcher :have_html_body do
      include ChainableBodyMatcher

      def actual_body_matches?(body)
        body.present? && body.include?("<html")
      end
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
          "expected response to #{description}\n#{other_matcher&.failure_message}"
        end
      end

      def actual_body(response)
        response.body
      end

      def actual_body_matches?(body)
        body.present?
      end
    end
  end
end
