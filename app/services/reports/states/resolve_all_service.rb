# frozen_string_literal: true

module Reports
  module States
    class ResolveAllService
      include ::ActiveModel::Model

      def initialize(reports)
        @reports = reports
      end

      attr_accessor :state, :reponse

      validates :state, presence: true, inclusion: %w[applicable inapplicable]

      def resolve(state, attributes = {})
        self.state = state.to_s

        assign_attributes(attributes) if attributes
        validate

        if errors.empty?
          @reports.resolve_all(self.state, **attributes.to_h.without(:state))
          Result::Success.new(@reports)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
