# frozen_string_literal: true

module States
  module ReportStates
    extend ActiveSupport::Concern

    STATES = %w[draft
                ready
                sent
                acknowledged
                denied
                processing
                approved
                rejected].freeze

    included do
      # Validations
      # ----------------------------------------------------------------------------
      validates :state, inclusion: { in: STATES }

      # Scopes
      # ----------------------------------------------------------------------------
      scope :draft,        -> { where(state: :draft) }
      scope :ready,        -> { where(state: :ready) }
      scope :sent,         -> { where(state: :sent) }
      scope :acknowledged, -> { where(state: :acknowledged) }
      scope :denied,       -> { where(state: :denied) }
      scope :processing,   -> { where(state: :processing) }
      scope :approved,     -> { where(state: :approved) }
      scope :rejected,     -> { where(state: :rejected) }

      scope :packing,     -> { where(state: %w[draft ready]) }
      scope :unassigned,  -> { where(state: %w[sent acknowledged]) }
      scope :assigned,    -> { where(state: %w[processing approved rejected]) }
      scope :unresolved,  -> { where(state: %w[sent acknowledged processing]) }
      scope :undenied,    -> { where(state: %w[sent acknowledged processing approved rejected]) }
      scope :transmitted, -> { where(state: %w[sent acknowledged denied processing approved rejected]) }
      scope :resolved,    -> { where(state: %w[approved rejected]) }

      # Predicates
      # ----------------------------------------------------------------------------
      def draft?
        state == "draft"
      end

      def ready?
        state == "ready"
      end

      def sent?
        state == "sent"
      end

      def acknowledged?
        state == "acknowledged"
      end

      def denied?
        state == "denied"
      end

      def processing?
        state == "processing"
      end

      def approved?
        state == "approved"
      end

      def rejected?
        state == "rejected"
      end

      def packing?
        draft? || ready?
      end

      def unassigned?
        sent? || acknowledged?
      end

      def assigned?
        processing? || approved? || rejected?
      end

      def unresolved?
        sent? || acknowledged? || processing?
      end

      def undenied?
        sent? || acknowledged? || processing? || approved? || rejected?
      end

      def transmitted?
        sent? || acknowledged? || denied? || processing? || approved? || rejected?
      end

      def resolved?
        approved? || rejected?
      end

      # Updates methods
      # ----------------------------------------------------------------------------
      def draft!
        return true if draft?

        update(
          state: "draft",
          ready_at: nil
        )
      end

      def ready!
        return true if ready?

        update(
          state: "ready",
          ready_at: Time.current
        )
      end

      def transmit!
        return true if transmitted?

        update(
          state: "sent",
          transmitted_at: Time.current
        )
      end

      def deny!
        return true if denied?

        update(
          state: "denied",
          denied_at: Time.current
        )
      end

      def acknowledge!
        return true if acknowledged?

        update(
          state: "acknowledged",
          acknowledged_at: Time.current
        )
      end

      def assign!
        return true if assigned?

        update(
          state: "processing",
          assigned_at: Time.current
        )
      end

      def self.assign_all!
        unassigned.update_all(
          state: "processing",
          assigned_at: Time.current
        )
      end

      def approve!
        return true if approved?

        update(
          state: "approved",
          approved_at: Time.current,
          rejected_at: nil
        )
      end

      def reject!
        return true if rejected?

        update(
          state: "rejected",
          rejected_at: Time.current
        )
      end
    end
  end
end
