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

            modal.with_hidden_field :form, self.class.name.demodulize.underscore
            modal.with_submit_action "Enregistrer"
            modal.with_close_action "Annuler"
          end
        end

        def requirements
          @requirements ||= ::Reports::RequirementsService.new(@report)
        end

        delegate :require_situation_majic?,
          :require_situation_evaluation?,
          :require_situation_evaluation_habitation?,
          :require_situation_evaluation_professionnel?,
          :require_proposition_evaluation?,
          :require_proposition_evaluation_habitation?,
          :require_proposition_evaluation_professionnel?,
          :require_proposition_affectation?,
          :require_proposition_adresse?,
          :require_proposition_consistance?,
          :require_proposition_correctif?,
          to: :requirements
      end
    end
  end
end
