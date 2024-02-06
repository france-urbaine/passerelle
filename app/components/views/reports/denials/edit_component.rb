# frozen_string_literal: true

module Views
  module Reports
    module Denials
      class EditComponent < ApplicationViewComponent
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
      end
    end
  end
end
