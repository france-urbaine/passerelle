# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class Form
        class PropositionExoneration < self
          def before_render
            @report.exonerations.build if @report.exonerations.empty?
          end

          def form_html_attributes
            { data: { controller: "nested-form", nested_form_wrapper_selector_value: ".nested-form-wrapper" } }
          end

          def status_choices
            I18n.t("enum.exoneration_status").map(&:reverse)
          end

          def base_choices
            I18n.t("enum.exoneration_base").map(&:reverse)
          end

          def code_collectivite_choices
            I18n.t("enum.exoneration_code_collectivite").map(&:reverse)
          end
        end
      end
    end
  end
end
