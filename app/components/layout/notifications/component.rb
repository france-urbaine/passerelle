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
        data = {
          scheme:  :default,
          options: {},
          actions: []
        }

        case flash[:notice]
        when String
          data[:header] = flash[:notice]
        when Hash
          notice = flash[:notice].symbolize_keys

          data[:scheme]  = notice.fetch(:scheme, :default).to_sym
          data[:options] = notice.slice(:delay, :icon, :icon_options)
          data[:header]  = notice.fetch(:header, nil)
          data[:body]    = notice.fetch(:body, nil)
        end

        data[:actions] = FlashAction.read_multi(flash[:actions]).map(&:symbolize_keys) if flash[:actions]
        data
      end
    end
  end
end
