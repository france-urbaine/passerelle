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
          disabled_email @user.unconfirmed_email, "arrow-path", t(".unconfirmed_email")
        elsif @user.confirmed?
          mail_to @user.email
        elsif @user.access_locked?
          disabled_email @user.email, "lock-closed", t(".locked")
        elsif @user.confirmation_period_expired?
          disabled_email @user.email, "no-symbol", t(".confirmation_period_expired")
        else
          disabled_email @user.email, "envelope", t(".unconfirmed_user")
        end
      end

      def disabled_email(email, icon, message)
        tag.span(class: "text-disabled", title: message) do
          concat icon_component(icon, class: "inline-block mr-2")
          concat email
          concat tag.span(message, class: "tooltip")
        end
      end
    end
  end
end
