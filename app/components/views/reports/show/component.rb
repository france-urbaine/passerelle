# frozen_string_literal: true

module Views
  module Reports
    module Show
      class Component < ApplicationViewComponent
        # FIXME: https://github.com/ViewComponent/view_component/issues/387
        # The PR on ViewComponent will eliminate the need to
        # create Subclasses to render other templates:
        #
        InformationPacking      = Class.new(self)
        InformationTransmitted  = Class.new(self)
        PropositionExoneration  = Class.new(self)
        PropositionAdresse      = Class.new(self)
        Enjeu                   = Class.new(self)
        Observations            = Class.new(self)
        Response                = Class.new(self)
        Note                    = Class.new(self)
        Documents               = Class.new(self)
        Chronology              = Class.new(self)

        def initialize(report)
          @report = report

          @report_completeness = ::Reports::CheckCompletenessService.new(@report)
          @report_completeness.validate unless @report.transmitted?

          super()
        end

        def show_motif?
          case current_organization
          when DDFIP, DGFIP
            @report.resolved?
          when Collectivity, Publisher
            @report.returned?
          end
        end

        def show_response?
          case current_organization
          when DDFIP, DGFIP
            true
          when Collectivity, Publisher
            @report.returned?
          end
        end

        def show_note?
          current_organization.is_a?(DDFIP)
        end

        private

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
            concat icon_component("exclamation-circle", "Une erreur est présente")
            concat tag.span(@report_completeness.errors.messages_for(attribute).first)
            ""
          end
        end

        def translate_enum(value, **)
          I18n.t(value, **, default: "") if value.present?
        end
      end
    end
  end
end
