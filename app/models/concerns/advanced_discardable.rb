# frozen_string_literal: true

module AdvancedDiscardable
  extend ActiveSupport::Concern

  included do
    scope :discarded_over, ->(duration) { discarded.where("discarded_at < ?", duration.ago) }
  end

  class_methods do
    def dispose_all
      update_all(discard_column => Time.current)
    end

    def undispose_all
      update_all(discard_column => nil)
    end
  end
end
