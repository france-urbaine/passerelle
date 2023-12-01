# frozen_string_literal: true

module Views
  module Audits
    class ListComponent < ApplicationViewComponent
      define_component_helper :audits_list_component

      attr_reader :audits, :pagy

      def initialize(audits, pagy = nil)
        @audits = audits
        @pagy   = pagy

        super()
      end
    end
  end
end
