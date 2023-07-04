# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Fields
        class SituationMajic < self
          def code_insee_options
            @report.collectivity.on_territory_communes.pluck(:name, :code_insee)
          end
        end
      end
    end
  end
end