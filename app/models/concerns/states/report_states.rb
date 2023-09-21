# frozen_string_literal: true

module States
  module ReportStates
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :packing,             -> { joins(:package).merge(Package.unscoped.packing) }
      scope :transmitted,         -> { joins(:package).merge(Package.unscoped.transmitted) }
      scope :delivered,           -> { joins(:package).merge(Package.unscoped.delivered) }
      scope :assigned,            -> { joins(:package).merge(Package.unscoped.assigned) }
      scope :returned,            -> { joins(:package).merge(Package.unscoped.returned) }
      scope :unreturned,          -> { joins(:package).merge(Package.unscoped.unreturned) }
      scope :pending,             -> { delivered.where(approved_at: nil, rejected_at: nil, debated_at: nil) }
      scope :updated_by_ddfip,    -> { approved.or(rejected).or(debated) }
      scope :approved,            -> { delivered.where.not(approved_at: nil) }
      scope :rejected,            -> { delivered.where.not(rejected_at: nil) }
      scope :debated,             -> { delivered.where.not(debated_at: nil) }

      # Predicates
      # ----------------------------------------------------------------------------
      delegate :transmitted?, :delivered?, :assigned?, :returned?, :unreturned?, to: :package, allow_nil: true

      def packing?
        package&.packing? || new_record?
      end

      def pending?
        delivered? && !approved_at? && !rejected_at? && !debated_at?
      end

      def approved?
        delivered? && approved_at?
      end

      def rejected?
        delivered? && rejected_at?
      end

      def debated?
        delivered? && debated_at?
      end

      def completed?
        completed_at.present?
      end

      # Updates methods
      # ----------------------------------------------------------------------------
      def approve!
        return true if approved?

        update_columns(
          approved_at: Time.current,
          rejected_at: nil,
          debated_at: nil
        )
      end

      def reject!
        return true if rejected?

        update_columns(
          rejected_at: Time.current,
          approved_at: nil,
          debated_at: nil
        )
      end

      def debate!
        return true if debated?
        return false if approved? || rejected?

        update_columns(debated_at: Time.current)
      end

      def complete!
        return true if completed?

        update_column(:completed_at, Time.current)
      end
    end
  end
end