# frozen_string_literal: true

module Views
  module Dashboard
    class Component < ApplicationViewComponent
      def initialize(reports)
        @reports = reports
        super()
      end

      def user_role
        @user_role ||= ::Users::RoleService.new(current_user).user_role
      end

      def count_reports(reports)
        displayed_count = reports.size
        total_count     = reports.unscope(:limit).count

        return if total_count <= displayed_count

        tag.div(class: "mr-4") do
          concat tag.b(displayed_count)
          concat " "
          concat displayed_count <= 1 ? "signalement affiché" : "signalements affichés"
          concat " sur "
          concat tag.b(total_count)
        end
      end

      def report_states_path(*states, as:)
        states = states
          .map! { |state| t(state, scope: "enum.search_state.#{as}") }
          .join(", ")

        reports_path(search: "etat:(#{states})")
      end
    end
  end
end
