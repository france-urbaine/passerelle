# frozen_string_literal: true

module Views
  module Users
    class OfficeListComponent < ApplicationViewComponent
      def initialize(users, pagy = nil, namespace:, office:)
        @users     = users
        @pagy      = pagy
        @namespace = namespace
        @office    = office
        super()
      end

      def before_render
        @users = @users.preload(:offices)
      end

      def office_user_policy
        "#{@namespace.to_s.classify}::Offices::UserPolicy".constantize
      end

      def user_policy
        "#{@namespace.to_s.classify}::UserPolicy".constantize
      end
    end
  end
end
