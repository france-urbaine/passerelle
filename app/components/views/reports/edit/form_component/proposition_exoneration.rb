# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class PropositionExoneration < self
          def before_render
            @report.exonerations.build if @report.exonerations.empty?
          end

          def form_html_attributes
            { data: { controller: "nested-form", nested_form_wrapper_selector_value: ".nested-form-wrapper" } }
          end

          def status_choices
            enum_options(:exoneration_status)
          end

          def base_choices
            enum_options(:exoneration_base)
          end

          def code_collectivite_choices
            enum_options(:exoneration_code_collectivite)
          end
        end
      end
    end
  end
end
