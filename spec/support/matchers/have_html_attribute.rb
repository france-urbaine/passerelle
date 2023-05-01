# frozen_string_literal: true

module Matchers
  module HaveHTMLAttribute
    extend RSpec::Matchers::DSL

    matcher :have_html_attribute do |expected|
      chain :to, :other_matcher

      chain :boolean do
        @boolean = true
      end

      chain :with_value do |value|
        @expected_value = value
      end

      match do |actual|
        validate_actual_type!(actual)

        @actual_attribute = actual[expected]
        actual_attribute_match? && (other_matcher.blank? || other_matcher.matches?(notice))
      end

      match_when_negated do |actual|
        validate_actual_type!(actual)

        @actual_attribute = actual[expected]
        @actual_attribute.nil? && (other_matcher.blank? || other_matcher.matches?(notice))
      end

      failure_message do
        "expected to #{description}\n#{other_matcher&.failure_message}"
      end

      def validate_actual_type!(actual)
        raise TypeError, "#{actual} is expected to  be a Capybara node" unless actual.is_a?(Capybara::Node::Simple)
      end

      def actual_attribute_match?
        if @boolean
          ["", "true", expected].include?(@actual_attribute)
        elsif @expected_value
          @expected_value == @actual_attribute
        else
          @actual_attribute.present?
        end
      end
    end
  end
end
