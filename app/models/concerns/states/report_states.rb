# frozen_string_literal: true

module States
  module ReportStates
    extend ActiveSupport::Concern

    STATES = %w[
      draft
      ready
      transmitted
      acknowledged
      accepted
      assigned
      applicable
      inapplicable
      approved
      canceled
      rejected
    ].freeze

    CONFIRMED_STATES    = %w[approved canceled].freeze
    RESOLVED_STATES     = (%w[applicable inapplicable] + CONFIRMED_STATES).freeze
    ASSIGNED_STATES     = (%w[assigned] + RESOLVED_STATES).freeze
    ACCEPTED_STATES     = (%w[accepted] + ASSIGNED_STATES).freeze
    ACKNOWLEDGED_STATES = (%w[acknowledged] + ACCEPTED_STATES + %w[rejected]).freeze
    TRANSMITTED_STATES  = (%w[transmitted] + ACKNOWLEDGED_STATES).freeze

    included do
      # Validations
      # ----------------------------------------------------------------------------
      validates :state, presence: true, inclusion: { in: STATES }

      # Scopes
      # ----------------------------------------------------------------------------
      scope :draft,        -> { where(state: "draft") }
      scope :ready,        -> { where(state: "ready") }
      scope :packing,      -> { where(state: %w[draft ready]) }

      scope :transmitted,  -> { where(state: TRANSMITTED_STATES) }
      scope :acknowledged, -> { where(state: ACKNOWLEDGED_STATES) }
      scope :accepted,     -> { where(state: ACCEPTED_STATES) }
      scope :assigned,     -> { where(state: ASSIGNED_STATES) }
      scope :resolved,     -> { where(state: RESOLVED_STATES) }
      scope :confirmed,    -> { where(state: CONFIRMED_STATES) }

      scope :applicable,   -> { where(state: "applicable") }
      scope :inapplicable, -> { where(state: "inapplicable") }
      scope :approved,     -> { where(state: "approved") }
      scope :rejected,     -> { where(state: "rejected") }
      scope :canceled,     -> { where(state: "canceled") }
      scope :returned,     -> { where(state: %w[approved canceled rejected]) }

      scope :transmittable,   -> { where(state: "ready") }
      scope :acceptable,      -> { where(state: %w[transmitted acknowledged accepted rejected]) }
      scope :rejectable,      -> { where(state: %w[transmitted acknowledged accepted rejected]) }
      scope :assignable,      -> { where(state: %w[accepted assigned]) }
      scope :resolvable,      -> { where(state: %w[assigned applicable inapplicable]) }
      scope :confirmable,     -> { where(state: %w[applicable inapplicable approved canceled]) }

      scope :waiting_for_acceptance,   -> { where(state: %w[transmitted acknowledged]) }
      scope :waiting_for_assignment,   -> { where(state: "accepted") }
      scope :waiting_for_resolution,   -> { where(state: "assigned") }
      scope :waiting_for_confirmation, -> { where(state: %w[applicable inapplicable]) }

      # Predicates
      # ----------------------------------------------------------------------------
      def draft?        = state == "draft"
      def ready?        = state == "ready"
      def packing?      = %w[draft ready].include?(state)

      def transmitted?  = TRANSMITTED_STATES.include?(state)
      def acknowledged? = ACKNOWLEDGED_STATES.include?(state)
      def accepted?     = ACCEPTED_STATES.include?(state)
      def assigned?     = ASSIGNED_STATES.include?(state)
      def resolved?     = RESOLVED_STATES.include?(state)
      def confirmed?    = CONFIRMED_STATES.include?(state)

      def applicable?   = state == "applicable"
      def inapplicable? = state == "inapplicable"
      def approved?     = state == "approved"
      def canceled?     = state == "canceled"
      def rejected?     = state == "rejected"
      def returned?     = %w[approved canceled rejected].include?(state)

      def transmittable? = state == "ready"
      def acceptable?    = %w[transmitted acknowledged accepted rejected].include?(state)
      def rejectable?    = %w[transmitted acknowledged accepted rejected].include?(state)
      def assignable?    = %w[accepted assigned].include?(state)
      def resolvable?    = %w[assigned applicable inapplicable].include?(state)
      def confirmable?   = %w[applicable inapplicable approved canceled].include?(state)

      def wait_for_acceptance?    = %w[transmitted acknowledged].include?(state)
      def wait_for_assignment?    = state == "accepted"
      def wait_for_resolution?    = state == "assigned"
      def wait_for_confirmation?  = %w[applicable inapplicable].include?(state)

      # Transition methods
      # ----------------------------------------------------------------------------

      def resume
        validate_state("ready", "draft") do
          self.state = "draft"
          self.completed_at = nil
        end
      end

      def complete
        validate_state("ready", "draft") do
          self.state = "ready"
          self.completed_at ||= Time.current
        end
      end

      def transmit
        validate_state("ready", "transmitted") do
          self.state = "transmitted"
          self.transmitted_at ||= Time.current
        end
      end

      def acknowledge
        validate_state("transmitted", "acknowledged") do
          self.state = "acknowledged"
          self.acknowledged_at ||= Time.current
        end
      end

      def accept
        validate_state("transmitted", "acknowledged", "accepted", "rejected") do
          self.state = "accepted"
          self.acknowledged_at ||= Time.current
          self.accepted_at ||= Time.current
          self.returned_at = nil
        end
      end

      def assign
        validate_state("accepted", "assigned") do
          self.state = "assigned"
          self.assigned_at ||= Time.current
        end
      end

      def resolve(state)
        raise ArgumentError unless %w[applicable inapplicable].include?(state.to_s)

        validate_state("assigned", "applicable", "inapplicable") do
          self.state = state

          if state_changed?
            self.resolved_at = Time.current
          else
            self.resolved_at ||= Time.current
          end
        end
      end

      def confirm
        validate_state("applicable", "inapplicable", "approved", "canceled") do
          case state
          when "applicable"   then self.state = "approved"
          when "inapplicable" then self.state = "canceled"
          end

          self.returned_at ||= Time.current
        end
      end

      def reject
        validate_state("transmitted", "acknowledged", "accepted", "rejected") do
          self.state = "rejected"
          self.acknowledged_at ||= Time.current
          self.returned_at ||= Time.current
          self.accepted_at = nil
        end
      end

      def undo_acceptance
        validate_state("accepted", "acknowledged") do
          self.state = "acknowledged"
          self.accepted_at = nil
          self.assigned_at = nil
          self.acknowledged_at ||= Time.current
        end
      end

      def undo_assignment
        validate_state("assigned", "accepted") do
          self.state = "accepted"
          self.assigned_at = nil
          self.acknowledged_at ||= Time.current
          self.accepted_at ||= Time.current
        end
      end

      def undo_resolution
        validate_state("applicable", "inapplicable", "assigned") do
          self.state = "assigned"
          self.resolution_motif = nil
          self.resolved_at = nil
        end
      end

      def undo_rejection
        validate_state("rejected", "acknowledged") do
          self.state = "acknowledged"
          self.returned_at = nil
          self.acknowledged_at ||= Time.current
        end
      end

      %w[
        resume!
        complete!
        transmit!
        acknowledge!
        accept!
        assign!
        resolve!
        confirm!
        reject!
        undo_acceptance!
        undo_assignment!
        undo_resolution!
        undo_rejection!
      ].each do |method|
        define_method method do |*args|
          public_send(method.delete("!"), *args)
          errors.empty? && save
        end
      end

      # Transition of multiple records
      # ----------------------------------------------------------------------------
      def self.transmit_all(**attributes)
        attributes[:state]            = "transmitted"
        attributes[:transmitted_at] ||= coalesce_sql_datetime(:transmitted_at)
        attributes[:updated_at]       = Time.current

        transmittable.update_all(attributes)
      end

      def self.accept_all(**attributes)
        attributes[:state]             = "accepted"
        attributes[:acknowledged_at] ||= coalesce_sql_datetime(:acknowledged_at)
        attributes[:accepted_at]     ||= coalesce_sql_datetime(:accepted_at)
        attributes[:returned_at]       = nil
        attributes[:updated_at]        = Time.current

        acceptable.update_all(attributes)
      end

      def self.assign_all(**attributes)
        attributes[:state]         = "assigned"
        attributes[:assigned_at] ||= coalesce_sql_datetime(:assigned_at)
        attributes[:updated_at]    = Time.current

        assignable.update_all(attributes)
      end

      def self.reject_all(**attributes)
        attributes[:state]             = "rejected"
        attributes[:acknowledged_at] ||= coalesce_sql_datetime(:acknowledged_at)
        attributes[:returned_at]     ||= coalesce_sql_datetime(:returned_at)
        attributes[:accepted_at]       = nil
        attributes[:updated_at]        = Time.current

        rejectable.update_all(attributes)
      end

      def self.resolve_all(state, **attributes)
        raise ArgumentError unless %w[applicable inapplicable].include?(state)

        attributes[:state]         = state
        attributes[:resolved_at] ||= coalesce_sql_datetime(:resolved_at)
        attributes[:updated_at]    = Time.current

        resolvable.update_all(attributes)
      end

      def self.confirm_all(**attributes)
        attributes[:state] = Arel.sql(<<~SQL.squish)
          CASE "reports"."state"
          WHEN 'applicable'::report_state   THEN 'approved'::report_state
          WHEN 'inapplicable'::report_state THEN 'canceled'::report_state
          ELSE "reports"."state"
          END
        SQL

        attributes[:returned_at] ||= coalesce_sql_datetime(:returned_at)
        attributes[:updated_at]    = Time.current

        confirmable.update_all(attributes)
      end

      # ----------------------------------------------------------------------------
      private

      def validate_state(*expected_states, &)
        if expected_states.include?(state)
          yield
        else
          errors.add(:state, :invalid_transition, current_state: state)
        end

        self
      end

      def self.coalesce_sql_datetime(column, value = nil)
        value ||= Time.current

        Arel.sql(sanitize_sql([<<~SQL.squish, value]))
          COALESCE("reports"."#{column}", ?)
        SQL
      end
    end
  end
end
