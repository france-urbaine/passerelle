# frozen_string_literal: true

module NotificationsHelper
  def flash_notifications
    tag.div(id: "notifications", class: "notifications") do
      notice = flash[:notice]
      return unless notice

      case notice
      when String
        scheme = :default
        title = notice
        options = {}
      when Hash
        notice.symbolize_keys!
        scheme      = notice.fetch(:scheme, :default).to_sym
        title       = notice.fetch(:title, nil)
        description = notice.fetch(:description, nil)
        options     = notice.slice(:icon, :delay)
      end

      actions = FlashAction.read_multi(flash[:actions])
      actions = Array.wrap(actions).map(&:symbolize_keys)

      render UI::NotificationComponent.new(scheme, **options) do |notification|
        notification.with_header { title } if title.present?
        notification.with_body   { description } if description.present?

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
