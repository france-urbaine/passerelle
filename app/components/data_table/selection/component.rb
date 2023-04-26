# frozen_string_literal: true

module DataTable
  module Selection
    class Component < ApplicationViewComponent
      renders_many :actions, "Action"

      attr_reader :datatable

      def initialize(datatable)
        @datatable = datatable
        super()
      end

      def can_select_all?
        params[:ids] != "all" &&
          params[:ids].size == @datatable.records.length &&
          @datatable.records.length < select_all_count
      end

      def selected_count
        params[:ids] == "all" ? select_all_count : params[:ids].size
      end

      def select_all_count
        if @datatable.pagination?
          @datatable.pagination.count
        else
          @datatable.records.length
        end
      end

      def pages_count
        @datatable.pagination.pages_count
      end

      def select_all_path
        url_for(
          params.slice(:search).permit!.merge(ids: "all")
        )
      end

      def selected_inflections_options
        model        = datatable.records.model
        key          = model.model_name.element
        translations = I18n.t(key, scope: "components.data_table/selection", default: nil)

        if translations
          InflectionsOptions.new(**translations)
        else
          InflectionsOptions.new(model)
        end
      end

      class Action < ::Button::Component
        def href_params
          super.merge(
            params.slice(:ids, :search, :order, :page).permit!
          )
        end
      end
    end
  end
end
