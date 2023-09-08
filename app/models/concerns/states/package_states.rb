# frozen_string_literal: true

module States
  module PackageStates
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :packing,      -> { where(transmitted_at: nil) }
      scope :transmitted,  -> { where.not(transmitted_at: nil) }
      scope :to_approve,   -> { transmitted.kept.where(approved_at: nil, rejected_at: nil) }
      scope :approved,     -> { transmitted.where.not(approved_at: nil).where(rejected_at: nil) }
      scope :returned,     -> { transmitted.where.not(rejected_at: nil) }
      scope :unrejected,   -> { transmitted.where(rejected_at: nil) }

      # Predicates
      # ----------------------------------------------------------------------------
      def packing?
        !transmitted_at?
      end

      def transmitted?
        transmitted_at?
      end

      def to_approve?
        transmitted? && kept? && approved_at.nil? && rejected_at.nil?
      end

      def approved?
        transmitted? && approved_at? && rejected_at.nil?
      end

      def returned?
        transmitted? && rejected_at?
      end

      def unrejected?
        transmitted? && rejected_at.nil?
      end

      # Updates methods
      # ----------------------------------------------------------------------------
      def transmit!
        return true if transmitted?

        touch(:transmitted_at)
      end

      def approve!
        return true if approved?

        update_columns(
          rejected_at: nil,
          approved_at: Time.current
        )
      end

      def return!
        return true if returned?

        update_columns(
          rejected_at: Time.current,
          approved_at: nil
        )
      end
    end
  end
end
