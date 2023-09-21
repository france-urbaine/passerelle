# frozen_string_literal: true

module States
  module PackageStates
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :packing,      -> { where(transmitted_at: nil) }
      scope :transmitted,  -> { where.not(transmitted_at: nil) }
      scope :delivered,    -> { transmitted.out_of_sandbox }
      scope :unresolved,   -> { delivered.where(assigned_at: nil, returned_at: nil) }
      scope :assigned,     -> { delivered.where.not(assigned_at: nil).where(returned_at: nil) }
      scope :returned,     -> { delivered.where.not(returned_at: nil) }
      scope :unreturned,   -> { delivered.where(returned_at: nil) }

      # Predicates
      # ----------------------------------------------------------------------------
      def packing?
        !transmitted_at?
      end

      def transmitted?
        transmitted_at?
      end

      def delivered?
        transmitted? && out_of_sandbox?
      end

      def unresolved?
        delivered? && assigned_at.nil? && returned_at.nil?
      end

      def assigned?
        delivered? && assigned_at? && returned_at.nil?
      end

      def returned?
        delivered? && returned_at?
      end

      def unreturned?
        delivered? && returned_at.nil?
      end

      def completed?
        completed_at.present?
      end

      # Updates methods
      # ----------------------------------------------------------------------------
      def transmit!
        return true if transmitted?

        touch(:transmitted_at)
      end

      def assign!
        return true if assigned?

        update_columns(
          returned_at: nil,
          assigned_at: Time.current
        )
      end

      def return!
        return true if returned?

        update_columns(
          returned_at: Time.current,
          assigned_at: nil
        )
      end

      def complete!
        return true if completed?

        update_column(:completed_at, Time.current)
      end
    end
  end
end