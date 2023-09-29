# frozen_string_literal: true

module States
  module PackageStates
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :transmitted,  -> { where(sandbox: false) }
      scope :unresolved,   -> { transmitted.where(assigned_at: nil, returned_at: nil) }
      scope :missed,       -> { raise NotImplementedError }
      scope :acknowledged, -> { raise NotImplementedError }
      scope :assigned,     -> { transmitted.where.not(assigned_at: nil).where(returned_at: nil) }
      scope :returned,     -> { transmitted.where.not(returned_at: nil) }
      scope :unreturned,   -> { transmitted.where(returned_at: nil) }

      # Predicates
      # ----------------------------------------------------------------------------
      def transmitted?
        !sandbox?
      end

      def unresolved?
        transmitted? && assigned_at.nil? && returned_at.nil?
      end

      def missed?
        raise NotImplementedError
      end

      def acknowledged?
        raise NotImplementedError
      end

      def assigned?
        transmitted? && assigned_at? && returned_at.nil?
      end

      def returned?
        transmitted? && returned_at?
      end

      def unreturned?
        transmitted? && returned_at.nil?
      end

      # Updates methods
      # ----------------------------------------------------------------------------
      def assign!
        return true if assigned?

        update(
          returned_at: nil,
          assigned_at: Time.current
        )
      end

      def return!
        return true if returned?

        update(
          returned_at: Time.current,
          assigned_at: nil
        )
      end
    end
  end
end
