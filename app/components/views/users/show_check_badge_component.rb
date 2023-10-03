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
        return " " unless checked?

        icon_component(ICON, label)
      end

      ICON = "check-badge"

      def label
        t(@attribute, scope: i18n_component_path)
      end

      def checked?
        @user[@attribute.to_s]
      end
    end
  end
end
