# frozen_string_literal: true

module Views
  module Reports
    module Edit
      class FormComponent
        class SituationMajic < self
          def code_insee_choices
            @report.collectivity.reportable_communes.order_by_name.pluck(:name, :code_insee)
          end
        end
      end
    end
  end
end
