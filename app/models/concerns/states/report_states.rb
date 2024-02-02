# frozen_string_literal: true

module States
  module ReportStates
    extend ActiveSupport::Concern

    STATES = %w[
      draft
      ready
      sent
      acknowledged
      denied
      processing
      approved
      rejected
    ].freeze

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

      # Transition methods
      # ----------------------------------------------------------------------------
      def resume
        validate_state("ready", "draft") do
          self.state = "draft"
          self.ready_at = nil
        end
      end

      def complete
        validate_state("ready", "draft") do
          self.state = "ready"
          self.ready_at ||= Time.current
        end
      end

      def transmit
        validate_state("ready", "sent") do
          self.state = "sent"
          self.transmitted_at ||= Time.current
        end
      end

      def acknowledge
        validate_state("sent", "acknowledged") do
          self.state = "acknowledged"
          self.acknowledged_at ||= Time.current
        end
      end

      def assign
        validate_state("sent", "acknowledged", "processing", "denied") do
          self.state = "processing"
          self.acknowledged_at ||= Time.current
          self.assigned_at ||= Time.current
          self.denied_at = nil
        end
      end

      def unassign
        validate_state("processing", "acknowledged") do
          self.state = "acknowledged"
          self.assigned_at = nil
          self.acknowledged_at ||= Time.current
        end
      end

      def deny
        validate_state("sent", "acknowledged", "processing", "denied") do
          self.state = "denied"
          self.acknowledged_at ||= Time.current
          self.assigned_at = nil
          self.denied_at ||= Time.current
        end
      end

      def undeny
        validate_state("denied", "acknowledged") do
          self.state = "acknowledged"
          self.denied_at = nil
          self.acknowledged_at ||= Time.current
        end
      end

      def approve
        validate_state("processing", "rejected", "approved") do
          self.state = "approved"
          self.approved_at ||= Time.current
          self.rejected_at = nil
        end
      end

      def unapprove
        validate_state("approved", "processing") do
          self.state = "processing"
          self.approved_at = nil
        end
      end

      def reject
        validate_state("processing", "rejected", "approved") do
          self.state = "rejected"
          self.approved_at = nil
          self.rejected_at ||= Time.current
        end
      end

      def unreject
        validate_state("rejected", "processing") do
          self.state = "processing"
          self.rejected_at = nil
        end
      end

      %w[
        resume!
        complete!
        transmit!
        acknowledge!
        assign!
        unassign!
        deny!
        undeny!
        approve!
        unapprove!
        reject!
        unreject!
      ].each do |method|
        define_method method do
          public_send(method.delete("!"))

          if errors.empty?
            save
          else
            false
          end
        end
      end

      alias_method :draft!, :resume!
      alias_method :ready!, :complete!

      def validate_state(*expected_states, &)
        if expected_states.include?(state)
          yield
        else
          errors.add(:state, :invalid_transition, current_state: state)
        end

        self
      end

      private :validate_state

      # Transition of multiple records
      # ----------------------------------------------------------------------------
      def self.transmit_all(**attributes)
        attributes[:state] = "sent"
        attributes[:transmitted_at] ||= Time.current

        packing.update_all(attributes)
      end

      def self.assign_all(**attributes)
        attributes[:state] = "processing"
        attributes[:denied_at] = nil
        attributes[:assigned_at] ||= Time.current

        where(
          state: %w[sent acknowledged denied]
        ).update_all(attributes)
      end

      def self.deny_all(**attributes)
        attributes[:state] = "denied"
        attributes[:assigned_at] = nil
        attributes[:denied_at] ||= Time.current

        where(
          state: %w[sent acknowledged processing]
        ).update_all(attributes)
      end

      def self.approve_all(**attributes)
        attributes[:state] = "approved"
        attributes[:rejected_at] = nil
        attributes[:approved_at] ||= Time.current

        where(
          state: %w[processing rejected]
        ).update_all(attributes)
      end

      def self.reject_all(**attributes)
        attributes[:state] = "approved"
        attributes[:approved_at] = nil
        attributes[:rejected_at] ||= Time.current

        where(
          state: %w[processing approved]
        ).update_all(attributes)
      end
    end
  end
end
