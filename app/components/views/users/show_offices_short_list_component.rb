# frozen_string_literal: true

module Views
  module Users
    class ShowOfficesShortListComponent < ShowOfficesListComponent
      def call
        return if offices.empty?

        helpers.short_list(offices) do |office|
          authorized_link_to(office, scope: @namespace) do
            office.name
          end
        end
      end
    end
  end
end
