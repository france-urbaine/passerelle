# frozen_string_literal: true

module Views
  module Audits
    class MessageComponent < ApplicationViewComponent
      attr_reader :audit

      def initialize(audit)
        @audit = audit
        super()
      end

      def call
        class_name = audit.auditable.class.name.underscore

        i18n_keys = [
          :"#{class_name}.#{audit.action}",
          :"default.#{audit.action}"
        ]

        t(
          i18n_keys.shift,
          scope:       i18n_component_path,
          default:     i18n_keys,
          application: application_name,
          username:    user_name
        ).html_safe
      end

      def application_name
        @audit.oauth_application&.name || t("unknown_part.application", scope: i18n_component_path)
      end

      def user_name
        @audit.user&.name || @audit.username.presence || t("unknown_part.username", scope: i18n_component_path)
      end
    end
  end
end
