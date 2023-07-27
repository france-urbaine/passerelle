# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class Form < ApplicationViewComponent
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
      end
    end
  end
end
