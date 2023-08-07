# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent < ApplicationViewComponent
      Enjeu              = Class.new(self)
      Observations       = Class.new(self)
      PropositionAdresse = Class.new(self)

      def initialize(report, redirection_path: nil)
        @report = report
        @redirection_path = redirection_path
        super()
      end

      private

      def modal_component
        render Modal::Component.new(redirection_path: @redirection_path) do |modal|
          yield(modal)

          modal.with_hidden_field :redirect, @redirection_path
          modal.with_hidden_field :form, self.class.name.demodulize.underscore

          modal.with_submit_action "Enregistrer"
          modal.with_close_action "Annuler"
        end
      end

      def requirements
        @requirements ||= ::Reports::RequirementsService.new(@report)
      end

      def respond_to_missing?(method, *)
        requirements.respond_to_predicate?(method, *) || super
      end

      def method_missing(method, *)
        if requirements.respond_to_predicate?(method, *)
          requirements.public_send(method, *)
        else
          super
        end
      end

      # Common helpers

      def enum_options(path)
        I18n.t(path, scope: "enum", default: []).map(&:reverse)
      end

      def parse_date(date)
        return unless date&.match(ApplicationRecord::DATE_REGEXP)

        # The API might send pseudo-date without days or months
        # This helper ignores missing information to return a full date
        #
        # We don't really care because date edited through this form should have been
        # filled by datefield inputs and be full-date.
        #
        args = $LAST_MATCH_INFO.values_at(:year, :month, :day).compact.map(&:to_i)
        Date.new(*args)
      end
    end
  end
end