# frozen_string_literal: true

module Views
  module Reports
    module Index
      class Component < ApplicationViewComponent
        def initialize(reports, pagy, transmission)
          @reports      = reports
          @pagy         = pagy
          @transmission = transmission
          super()
        end
      end
    end
  end
end
