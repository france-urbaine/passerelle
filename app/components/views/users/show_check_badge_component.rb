# frozen_string_literal: true

module Views
  module Users
    class ShowCheckBadgeComponent < ApplicationViewComponent
      def initialize(user, attribute)
        @user      = user
        @attribute = attribute
        super()
      end

      def checked?
        @user[@attribute.to_s]
      end

      TITLES = {
        super_admin:        "Administrateur de FiscaHub",
        organization_admin: "Administrateur de l'organisation"
      }.freeze

      def call
        # Render a empty string to avoid empty placeholder
        return " " unless checked?

        svg_icon("check-badge", TITLES[@attribute])
      end
    end
  end
end
