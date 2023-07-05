# frozen_string_literal: true

module Views
  module Reports
    module UpdateForm
      class Fields
        class Priority < self
          def priority_choices
            I18n.t("enum.priority").map(&:reverse)
          end
        end
      end
    end
  end
end
