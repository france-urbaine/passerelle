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

        # State should be one of applicable or inapplicable
        #
        @report.errors.add(:state, :inclusion) unless %w[applicable inapplicable].include?(state.to_s)

        # Motif should be filled
        #
        @report.errors.add(:resolution_motif, :blank) if @report.resolution_motif.nil?

        # Motif should be one of resolution_motif_applicable or resolution_motif_inapplicable
        #
        @report.errors.add(:resolution_motif, :inclusion) unless resolution_motif_valid?(state)

        @report.resolve!(state) if @report.errors.empty?

        build_result
      end

      def undo
        @report.undo_resolution!

        build_result
      end

      private

      def resolution_motif_valid?(state)
        (state.to_s == "applicable" &&
         @report.resolution_motif &&
           @report.resolution_motif.to_sym.in?(I18n.t("enum.resolution_motif_applicable").keys)) ||
          (state.to_s == "inapplicable" &&
            @report.resolution_motif &&
              @report.resolution_motif.to_sym.in?(I18n.t("enum.resolution_motif_inapplicable").keys))
      end

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
