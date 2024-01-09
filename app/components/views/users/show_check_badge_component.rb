# frozen_string_literal: true

module Views
  module Users
    class ShowCheckBadgeComponent < ApplicationViewComponent
      def initialize(user, attribute)
        @user      = user
        @attribute = attribute
        super()
      end

      def call
        # Render a empty string to avoid empty placeholder
        return " ".html_safe unless checked?

        icon_component(ICON, label)
      end

      ICON = "check-badge"

      def label
        t(".#{@attribute}")
      end

      def checked?
        @user[@attribute.to_s]
      end
    end
  end
end
