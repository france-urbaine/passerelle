# frozen_string_literal: true

module Reports
  module States
    class AcceptAllService
      include ::ActiveModel::Model
      include ::ActiveModel::Validations

      def initialize(reports)
        @reports = reports
      end

      def accept(attributes = {})
        assign_attributes(attributes) if attributes
        validate

        if errors.empty?
          @reports.accept_all(**attributes.to_h)
          Result::Success.new(@reports)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
