# frozen_string_literal: true

module Matchers
  module HaveFlash
    extend RSpec::Matchers::DSL

    matcher :have_flash_notice do
      chain :to, :other_matcher

      match do |actual|
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::Flash::FlashHash)

        notice = actual["notice"]
        notice.present? && (other_matcher.blank? || other_matcher.matches?(notice))
      end

      failure_message do
        "expected to #{description}\n#{other_matcher&.failure_message}"
      end
    end

    matcher :have_flash_actions do
      chain :to, :other_matcher

      match do |actual|
        actions = extract_actions(actual)
        actions.present? && (other_matcher.blank? || other_matcher.matches?(actions))
      end

      failure_message do
        "expected to #{description}\n#{other_matcher&.failure_message}"
      end

      def extract_actions(actual)
        raise TypeError, "Invalid response type: #{actual}" unless actual.is_a?(ActionDispatch::Flash::FlashHash)

        return actual["actions"] if actual["actions"].blank?

        FlashAction.read_multi(actual["actions"])
      end
    end
  end
end
