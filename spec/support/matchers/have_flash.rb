# frozen_string_literal: true

module Matchers
  module HaveFlash
    extend RSpec::Matchers::DSL

    matcher :have_flash_notice do
      chain :to, :other_matcher

      match do |actual|
        raise TypeError, "Expect a FlashHash, got instead: #{actual}" unless actual.is_a?(
          ActionDispatch::Flash::FlashHash
        )

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
        raise TypeError, "Expect a FlashHash, got instead: #{actual}" unless actual.is_a?(
          ActionDispatch::Flash::FlashHash
        )

        actions = actual["actions"]
        actions.present? && (other_matcher.blank? || other_matcher.matches?(actions))
      end

      failure_message do
        "expected to #{description}\n#{other_matcher&.failure_message}"
      end
    end
  end
end
