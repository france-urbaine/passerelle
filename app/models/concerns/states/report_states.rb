# frozen_string_literal: true

module States
  module ReportStates
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :incomplete,             -> { where(completed_at: nil) }
      scope :completed,              -> { where.not(completed_at: nil) }

      scope :packing,                -> { where(package_id: nil) }
      scope :packed,                 -> { where.not(package_id: nil) }

      scope :in_transmission,        ->(transmission_id) { where(transmission_id: transmission_id) }
      scope :not_in_transmission,    lambda { |transmission_id|
                                       where.not(transmission_id: transmission_id)
                                         .or(where(transmission_id: nil))
                                     }

      scope :transmissible,          ->(transmission_id) { completed.packing.not_in_transmission(transmission_id) }

      scope :transmitted_to_sandbox, -> { joins(:package).merge(Package.unscoped.sandbox) }
      scope :transmitted,            -> { joins(:package).merge(Package.unscoped.transmitted) }
      scope :unresolved,             -> { joins(:package).merge(Package.unscoped.unresolved) }
      scope :missed,                 -> { joins(:package).merge(Package.unscoped.missed) }
      scope :acknowledged,           -> { joins(:package).merge(Package.unscoped.acknowledged) }
      scope :assigned,               -> { joins(:package).merge(Package.unscoped.assigned) }
      scope :returned,               -> { joins(:package).merge(Package.unscoped.returned) }
      scope :unreturned,             -> { joins(:package).merge(Package.unscoped.unreturned) }

      scope :operative,              -> { assigned.where(approved_at: nil, rejected_at: nil) }
      scope :pending,                -> { assigned.where(approved_at: nil, rejected_at: nil, debated_at: nil) }
      scope :debated,                -> { assigned.where.not(debated_at: nil) }
      scope :approved,               -> { assigned.where.not(approved_at: nil) }
      scope :rejected,               -> { assigned.where.not(rejected_at: nil) }
      scope :concluded,              -> { approved.or(rejected) }
      scope :examined,               -> { approved.or(rejected).or(debated) }

      # Predicates
      # ----------------------------------------------------------------------------
      def incomplete?
        completed_at.nil?
      end

      def completed?
        completed_at?
      end

      def packing?
        package_id.nil?
      end

      def packed?
        package_id?
      end

      def transmitted_to_sandbox?
        package&.sandbox?
      end

      %i[
        transmitted?
        unresolved?
        missed?
        acknowledged?
        assigned?
        returned?
        unreturned?
      ].each do |method_name|
        define_method method_name do
          packed? && package.public_send(method_name)
        end
      end

      def operative?
        assigned? && approved_at.nil? && rejected_at.nil?
      end

      def pending?
        assigned? && approved_at.nil? && rejected_at.nil? && debated_at.nil?
      end

      def debated?
        assigned? && debated_at?
      end

      def approved?
        assigned? && approved_at?
      end

      def rejected?
        assigned? && rejected_at?
      end

      def concluded?
        approved? || rejected?
      end

      def examined?
        approved? || rejected? || debated?
      end

      def transmissible?
        completed? && package.nil?
      end

      def in_active_transmission?
        transmissible? && transmission_id? && !transmitted?
      end

      # Updates methods
      # ----------------------------------------------------------------------------
      def complete!
        return true if completed?

        touch(:completed_at)
      end

      def incomplete!
        update(completed_at: nil)
      end

      def debate!
        return false if approved? || rejected?
        return true if debated?

        touch(:debated_at)
      end

      def approve!
        return true if approved?

        update(
          approved_at: Time.current,
          rejected_at: nil,
          debated_at:  nil
        )
      end

      def reject!
        return true if rejected?

        update(
          rejected_at: Time.current,
          approved_at: nil,
          debated_at:  nil
        )
      end
    end
  end
end
