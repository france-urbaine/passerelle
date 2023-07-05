# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component < ApplicationViewComponent
        # FIXME: A PR on ViewComponent will eliminate the need to
        # create Subclasses to render other templates:
        # https://github.com/ViewComponent/view_component/issues/387
        #
        InformationPacking      = Class.new(self)
        InformationTransmitted  = Class.new(self)
        PropositionExoneration  = Class.new(self)
        PropositionAdresse      = Class.new(self)
        Enjeu                   = Class.new(self)
        Observations            = Class.new(self)
        Documents               = Class.new(self)

        def initialize(report)
          @report = report

          @report_completeness = ::Reports::CheckCompletenessService.new(@report)
          @report_completeness.validate unless @report.transmitted?

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
          :require_proposition_exoneration?,
          to: :requirements

        # Helpers
        # ----------------------------------------------------------------------
        def render_valid_content(attribute, &)
          if @report.packing? && completeness_errors_on?(attribute)
            completeness_error_message(attribute)
          elsif block_given?
            capture(&)
          end
        end

        def completeness_errors_on?(attribute)
          @report_completeness.errors.include?(attribute)
        end

        def completeness_error_message(attribute)
          tag.span class: "flex space-x-2 text-red-500" do
            concat helpers.svg_icon("exclamation-circle", "Une erreur est présente")
            concat tag.span(@report_completeness.errors.messages_for(attribute).first)
            ""
          end
        end
      end
    end
  end
end
