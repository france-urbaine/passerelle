# frozen_string_literal: true

module Views
  module Reports
    module Assignments
      class EditComponent < ApplicationViewComponent
        def initialize(report, referrer: nil)
          @report   = report
          @referrer = referrer
          super()
        end

        def office_id_choices
          current_ddfip.offices.order(:name).pluck(:name, :id)
        end

        def office_id_options
          { prompt: "Sélectionnez un guichet" }
        end

        def autofocus_on_submit_button?
          # Put the focus on the submit button, when the report is not yet assigned
          # and an office is already selected.
          !@report.assigned? && office_id_choices.any? { |(_name, id)| @report.office_id == id }
        end

        def autofocus_on_select?
          !autofocus_on_submit_button?
        end

        private

        def current_ddfip
          @current_ddfip ||= current_user.organization
        end
      end
    end
  end
end
