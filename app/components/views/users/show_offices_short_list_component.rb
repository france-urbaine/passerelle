# frozen_string_literal: true

module Views
  module Users
    class ShowOfficesShortListComponent < ShowOfficesListComponent
      def call
        return if offices.empty?

        helpers.short_list(offices) do |office|
          authorized_link_to(office, namespace: @namespace)
        end
      end
    end
  end
end
