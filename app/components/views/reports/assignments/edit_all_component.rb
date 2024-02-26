# frozen_string_literal: true

module Views
  module Reports
    module Assignments
      class EditAllComponent < ApplicationViewComponent
        def initialize(reports, selected: nil, service: nil, referrer: nil)
          @reports  = reports
          @selected = selected
          @service  = service || ::Reports::States::AssignAllService.new(reports)
          @referrer = referrer
          super()
        end

        def before_render
          return if @service.errors.any?
          return if @service.office_id

          office_ids = @reports.distinct.pluck(:office_id).compact
          @service.office_id = office_ids[0] if office_ids.size == 1
        end

        def reports_count
          @reports_count ||= @reports.count
        end

        def selected_count
          @selected_count ||= @selected || reports_count
        end

        def assigned_count
          @assigned_count ||= @reports.assigned.count
        end

        def ignored_count
          @ignored_count ||= selected_count - reports_count
        end

        def office_id_choice
          return [] unless current_user

          current_ddfip.offices.order(:name).pluck(:name, :id)
        end

        def office_id_options
          {}.tap do |options|
            options[:prompt] = "Sélectionnez un guichet"
            options[:autofocus] = true
          end
        end

        def autofocus_on_submit_button?
          # Put the focus on the submit button if all reports get the same office
          # assigne or pre-assigned, and the option is alread selected
          #
          @service.office_id.present?
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
