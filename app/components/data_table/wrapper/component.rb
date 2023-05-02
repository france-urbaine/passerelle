# frozen_string_literal: true

module DataTable
  module Wrapper
    class Component < ApplicationViewComponent
      renders_one :selection
      renders_one :header
      renders_one :table

      attr_reader :datatable

      delegate :turbo_frame, :turbo_frame_selection_bar, to: :datatable

      def initialize(datatable)
        @datatable = datatable
        super()
      end

      def wrapped_in_frame?
        datatable.selection? || datatable.search? || datatable.pagination? || datatable.order_columns?
      end

      def selection_controller?
        datatable.selection? || datatable.checkboxes?
      end

      def selection_component?
        datatable.selection?
      end

      def render_selection_component?
        datatable.selection? && params[:ids].present?
      end

      def render_header?
        datatable.search? || datatable.pagination?
      end

      def render_selection_frame?
        render_selection_component? && turbo_frame_request_id == turbo_frame_selection_bar
      end

      def render_header_frame?
        render_header? && turbo_frame_request_id == turbo_frame_selection_bar
      end

      def turbo_frame_request_id
        request.headers["Turbo-Frame"]
      end
    end
  end
end
