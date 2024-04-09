# frozen_string_literal: true

module PolicyTestHelpers
  module ScopesHelpers
    extend ActiveSupport::Concern

    included do
      let(:scope_options) { |e| e.metadata.fetch(:scope_options, {}) }
    end

    def apply_params_scope(params, type: :action_controller_params, **)
      params = ActionController::Parameters.new(params)
      params = policy.apply_scope(params, type:, **)
      params&.to_hash&.symbolize_keys
    end

    def apply_relation_scope(target, type: :active_record_relation, **)
      policy.apply_scope(target, type:, scope_options:, **)
    end
  end
end
