# frozen_string_literal: true

module Datatable
  module Selection
    class HeaderBarComponent < ViewComponent::Base
      def initialize(datatable)
        @datatable = datatable
        super()
      end

      def selected_count
        params[:ids] == "all" ? select_all_count : params[:ids].size
      end

      def select_all_count
        @datatable.pagy.count
      end

      def pages_count
        @datatable.pagy.pages
      end

      def select_all_path
        helpers.url_for(
          params.slice(:search).permit!.merge(ids: "all")
        )
      end

      def can_select_all?
        params[:ids] != "all" &&
          params[:ids].size == @datatable.records.length &&
          @datatable.records.length < @datatable.pagy.count
      end

      def singular_inflection
        @datatable.singular_inflection
      end

      def plural_inflection
        @datatable.plural_inflection
      end

      def selected_singular_inflection
        label = singular_inflection
        label += @datatable.feminine_inflection? ? " sélectionnée" : " sélectionné"
        label
      end

      def selected_plural_inflection
        label = @datatable.plural_inflection
        label += @datatable.feminine_inflection? ? " sélectionnées" : " sélectionnés"
        label
      end
    end
  end
end
