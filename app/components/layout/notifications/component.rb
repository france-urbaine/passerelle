# frozen_string_literal: true

module Layout
  module Notifications
    class Component < ApplicationViewComponent
      def call
        return unless flash[:notice]

        notice = extract_flash_notice
        return unless notice

        tag.div(class: "notifications", id: "notifications") do
          render UI::Notification::Component.new(
            notice[:scheme],
            **notice[:options]
          ) do |notification|
            notification.with_header { notice[:header] } if notice[:header].present?
            notification.with_body   { notice[:body]   } if notice[:body].present?

            notice[:actions].each do |action|
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

      def extract_flash_notice
        case flash[:notice]
        when String
          {
            scheme:  :default,
            header:  flash[:notice],
            options: {},
            actions: []
          }
        when Hash
          notice  = flash[:notice].symbolize_keys
          actions = flash[:actions]&.map(&:symbolize_keys) || []

          {
            scheme:  notice.fetch(:scheme, :default).to_sym,
            header:  notice.fetch(:header, nil),
            body:    notice.fetch(:body, nil),
            options: notice.slice(:delay, :icon, :icon_options),
            actions: actions
          }
        end
      end
    end
  end
end
