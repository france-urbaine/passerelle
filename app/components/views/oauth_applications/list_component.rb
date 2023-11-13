# frozen_string_literal: true

module Views
  module OauthApplications
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        sandbox
        name
        uid
        secret
        created_at
      ].freeze

      def initialize(oauth_applications, pagy = nil, namespace:, parent: nil)
        @oauth_applications = oauth_applications
        @pagy               = pagy
        @namespace          = namespace
        @parent             = parent
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?
      end

      def with_column(name)
        columns << name
      end

      def columns
        @columns ||= []
      end

      def nested?
        @parent
      end

      def allow_action_to?(action, oauth_application)
        allowed_to?(action, oauth_application, namespace: @namespace.to_s.classify.constantize)
      end
    end
  end
end
