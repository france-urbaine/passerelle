# frozen_string_literal: true

module Views
  module Users
    class ShowOtpMethodComponent < ApplicationViewComponent
      def initialize(user)
        @user = user
        super()
      end

      def call
        # Render a empty string to avoid empty placeholder
        return " " unless @user.confirmed? && icon

        icon_component(icon, label) if icon
      end

      ICONS = {
        "2fa"   => "device-phone-mobile",
        "email" => "envelope"
      }.freeze

      def icon
        ICONS[@user.otp_method]
      end

      def label
        t(".#{@user.otp_method}")
      end
    end
  end
end
