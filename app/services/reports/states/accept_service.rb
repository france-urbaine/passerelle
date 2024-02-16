# frozen_string_literal: true

module Reports
  module States
    class AcceptService
      include ::ActiveModel::Validations

      def initialize(report)
        @report = report
      end

      def accept(attributes = {})
        @report.assign_attributes(attributes) if attributes
        @report.accept! if @report.valid?

        build_result
      end

      def undo
        @report.undo_acceptance!

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
