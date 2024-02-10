# frozen_string_literal: true

module Reports
  module States
    class ConfirmService
      include ::ActiveModel::Validations

      def initialize(report)
        @report = report
      end

      def confirm(attributes = {})
        @report.assign_attributes(attributes) if attributes
        @report.confirm! if @report.valid?

        build_result
      end

      def undo
        raise NotImplementedError
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
