# frozen_string_literal: true

module Views
  module Reports
    module Assignments
      class FormComponent < ApplicationViewComponent
        def initialize(report, referrer: nil)
          @report   = report
          @referrer = referrer
          super()
        end

        def redirection_path
          if @referrer.nil? && @report.errors.any? && params[:redirect]
            params[:redirect]
          else
            @referrer
          end
        end

        def office_id_choice
          current_ddfip.offices.pluck(:name, :id)
        end

        def office_id_options
          {}.tap do |options|
            options[:prompt] = "Sélectionnez un guichet" if @report.office_id.nil? && @report.errors.empty?
            options[:autofocus] = true
          end
        end

        private

        def current_ddfip
          @current_ddfip ||= current_user.organization
        end
      end
    end
  end
end
