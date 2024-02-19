# frozen_string_literal: true

module Reports
  module States
    class RejectAllService
      include ::ActiveModel::Model
      include ::ActiveModel::Validations

      def initialize(reports)
        @reports = reports
      end

      attr_accessor :reponse

      def reject(attributes = {})
        assign_attributes(attributes) if attributes
        validate

        if errors.empty?
          @reports.reject_all(**attributes.to_h)
          Result::Success.new(@reports)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
