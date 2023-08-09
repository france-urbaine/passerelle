# frozen_string_literal: true

module Views
  module Users
    class ShowEmailComponent < ApplicationViewComponent
      def initialize(user)
        @user = user
        super()
      end

      def call
        if @user.unconfirmed_email?
          message = t("user_email.unconfirmed_email")

          tag.span(class: "text-disabled", title: message) do
            concat svg_icon("arrow-path", class: "inline-block mr-2")
            concat @user.unconfirmed_email
            concat tag.span(message, class: "tooltip")
          end
        elsif @user.confirmed?
          mail_to @user.email
        else
          message = t("user_email.unconfirmed_user")

          tag.span(class: "text-disabled", title: message) do
            concat svg_icon("envelope", class: "inline-block mr-2")
            concat @user.email
            concat tag.span(message, class: "tooltip")
          end
        end
      end
    end
  end
end
