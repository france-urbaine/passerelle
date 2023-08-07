# frozen_string_literal: true

module Views
  module Reports
    class EditFormComponent
      class SituationMajic < self
        def code_insee_choices
          @report.collectivity.on_territory_communes.pluck(:name, :code_insee)
        end
      end
    end
  end
end
