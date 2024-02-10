# frozen_string_literal: true

module Views
  module Reports
    module Show
      module Breadcrumbs
        class Component < ApplicationViewComponent
          def initialize(report)
            @report = report
            super()
          end
        end
      end
    end
  end
end
