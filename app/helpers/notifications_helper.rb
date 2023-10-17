# frozen_string_literal: true

module NotificationsHelper
  def flash_notifications
    tag.div(id: "notifications", class: "notifications") do
      notice = flash[:notice]
      return unless notice

      actions = FlashAction.read_multi(flash[:actions])

      render UI::NotificationComponent.new(notice, actions)
    end
  end
end
