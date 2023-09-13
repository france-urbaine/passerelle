# frozen_string_literal: true

module States
  module ReportStates
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :packing,             -> { joins(:package).merge(Package.unscoped.packing) }
      scope :transmitted,         -> { joins(:package).merge(Package.unscoped.transmitted) }
      scope :delivered,           -> { transmitted.out_of_sandbox }
      scope :assigned,            -> { joins(:package).merge(Package.unscoped.assigned) }
      scope :returned,            -> { joins(:package).merge(Package.unscoped.returned) }
      scope :pending,             -> { delivered.where(approved_at: nil, rejected_at: nil, debated_at: nil) }
      scope :updated_by_ddfip,    -> { approved.or(rejected).or(debated) }
      scope :approved,            -> { delivered.where.not(approved_at: nil) }
      scope :rejected,            -> { delivered.where.not(rejected_at: nil) }
      scope :debated,             -> { delivered.where.not(debated_at: nil) }
      scope :unreturned_packages, -> { joins(:package).merge(Package.unscoped.unreturned) }

      # Predicates
      # ----------------------------------------------------------------------------
      delegate :transmitted?, to: :package, allow_nil: true

      def packing?
        package&.packing? || new_record?
      end

      def delivered?
        transmitted? && all_kept? && out_of_sandbox?
      end

      def assigned?
        package&.assigned?
      end

      def returned?
        package&.returned?
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

      def unreturned_packages?
        package.unreturned?
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
    end
  end
end
