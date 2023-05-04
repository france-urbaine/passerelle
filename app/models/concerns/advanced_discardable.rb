# frozen_string_literal: true

module AdvancedDiscardable
  extend ActiveSupport::Concern

  included do
    scope :discarded_over, ->(duration) { discarded.where("discarded_at < ?", duration.ago) }
  end

  class_methods do
    def quickly_discard_all
      update_all(discard_column => Time.current)
    end

    def quickly_undiscard_all
      update_all(discard_column => nil)
    end
  end
end
