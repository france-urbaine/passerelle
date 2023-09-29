# frozen_string_literal: true

module States
  module Sandbox
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :sandbox,        -> { where(sandbox: true) }
      scope :out_of_sandbox, -> { where(sandbox: false) }

      # Predicates
      # ----------------------------------------------------------------------------
      def out_of_sandbox?
        !sandbox?
      end
    end
  end
end
