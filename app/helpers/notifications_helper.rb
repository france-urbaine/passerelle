# frozen_string_literal: true

module NotificationsHelper
  def flash_notifications
    tag.div(id: "notifications", class: "notifications") do
      notice = flash[:notice]
      return unless notice

      scheme  = :default
      options = {}
      header  = notice

      if notice.is_a?(Hash)
        notice.symbolize_keys!

        scheme  = notice.fetch(:scheme, :default).to_sym
        options = notice.slice(:icon, :delay)
        header  = notice.fetch(:header, nil)
        body    = notice.fetch(:body, nil)
      end

      actions = FlashAction.read_multi(flash[:actions])
      actions = Array.wrap(actions).map(&:symbolize_keys)

      render UI::NotificationComponent.new(scheme, **options) do |notification|
        notification.with_header { header } if header.present?
        notification.with_body   { body } if body.present?

        actions.each do |action|
          notification.with_action(
            action[:label],
            action[:url],
            method: action[:method],
            params: action[:params]
          )
        end
      end
    end
  end
end
