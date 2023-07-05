# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Fields < ApplicationViewComponent
        Enjeu              = Class.new(self)
        Observations       = Class.new(self)
        PropositionAdresse = Class.new(self)

        def initialize(report)
          @report = report
          super()
        end

        private

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
