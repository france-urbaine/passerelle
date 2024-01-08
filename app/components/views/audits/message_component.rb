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
        type    = audit.auditable_type.underscore
        key     = ".#{type}.#{audit.action}"
        default = ".default.#{audit.action}"
        options = {
          application_name: ->(*) { application_name },
          user_name:        ->(*) { user_name }
        }

        t(
          key,
          **options,
          default: ->(*) { t(default, **options) }
        ).html_safe
      end

      def application_name
        if @audit.oauth_application&.name
          html_escape(@audit.oauth_application.name)
        else
          t(".unknown_part.application_name")
        end
      end

      def user_name
        if @audit.user
          html_escape(@audit.user&.name)
        elsif @audit.username.present?
          html_escape(@audit.username)
        else
          t(".unknown_part.user_name")
        end
      end
    end
  end
end
