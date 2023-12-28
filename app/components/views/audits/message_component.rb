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

        t(key, **options, default: ->(*) { t(default, **options) })
      end

      def application_name
        @audit.oauth_application&.name || t(".unknown_part.application_name")
      end

      def user_name
        @audit.user&.name || @audit.username.presence || t(".unknown_part.user_name")
      end
    end
  end
end
