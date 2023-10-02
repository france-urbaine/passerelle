# frozen_string_literal: true

module Views
  module Transmissions
    class ButtonLabelComponent < ApplicationViewComponent
      def initialize(transmission)
        @transmission = transmission
        super()
      end

      def call
        I18n.t(i18n_component_path, count: @transmission.reports.count)
      end
    end
  end
end
