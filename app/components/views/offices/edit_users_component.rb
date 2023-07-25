# frozen_string_literal: true

module Views
  module Offices
    class EditUsersComponent < ApplicationViewComponent
      def initialize(office, scope:, redirection_path: nil)
        @office           = office
        @scope            = scope
        @redirection_path = redirection_path
        super()
      end

      def form_url
        polymorphic_path([@scope, @office, :users].compact)
      end

      def new_user_url
        url_args = [:new, @scope, @office, :user]
        params   = { redirect: @redirection_path }

        polymorphic_path(url_args.compact, params)
      end

      def suggested_users
        @office.ddfip.users.order(:created_at)
      end
    end
  end
end
