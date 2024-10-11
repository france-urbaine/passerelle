# frozen_string_literal: true

module Reports
  module States
    class ResolveService
      include ::ActiveModel::Model
      include ::ActiveModel::Validations::Callbacks

      def initialize(report)
        @report = report
      end

      attr_accessor :state, :resolution_motif, :reponse

      validates :state,            inclusion: %w[applicable inapplicable]
      validates :resolution_motif, presence: true
      validates :resolution_motif, inclusion: { in: :valid_resolution_motifs, allow_blank: true }
      validate  :validate_record

      after_validation :sync_errors

      def resolve(state, attributes = {})
        # Assign the state and the existing motif if it exists
        # to perform service validations
        #
        self.state            = state.to_s
        self.resolution_motif = @report.resolution_motif

        # Assign an validatte both service & record
        #
        assign_attributes(attributes) if attributes
        validate

        @report.resolve!(state) if errors.empty?

        build_result
      end

      def undo
        @report.undo_resolution!

        build_result
      end

      private

      def assign_attributes(attributes)
        @report.assign_attributes(attributes)
        super(attributes.slice(:resolution_motif))
      end

      def valid_resolution_motifs
        enum_path = ["enum.resolution_motif"]
        enum_path << @report.form_type
        enum_path << (state == "applicable" ? "applicable" : "inapplicable")

        I18n.t(enum_path.join("."), default: {}).keys.map(&:to_s)
      end

      def validate_record
        errors.merge!(@report.errors) unless @report.valid?
      end

      def sync_errors
        @report.errors.clear
        @report.errors.merge!(errors)
      end

      def build_result
        # Merge errors if resolve! or undo_resolution! failed.
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
