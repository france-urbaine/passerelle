# frozen_string_literal: true

module Reports
  module States
    class ResolveService
      include ::ActiveModel::Validations

      def initialize(report)
        @report = report
      end

      def resolve(state, attributes = {})
        @report.assign_attributes(attributes) if attributes
        @report.validate
        @report.errors.add(:state, :inclusion) unless %w[applicable inapplicable].include?(state.to_s)
        @report.resolve!(state) if @report.errors.empty?

        build_result
      end

      def undo
        @report.undo_resolution!

        build_result
      end

      private

      def build_result
        errors.clear
        errors.merge!(@report.errors)

        if errors.empty?
          Result::Success.new(@report)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
