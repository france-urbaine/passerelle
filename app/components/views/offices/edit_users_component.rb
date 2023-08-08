# frozen_string_literal: true

module Views
  module Offices
    class EditUsersComponent < ApplicationViewComponent
      def initialize(office, scope:, referrer: nil)
        @office   = office
        @scope    = scope
        @referrer = referrer
        super()
      end

      def form_url
        polymorphic_path([@scope, @office, :users].compact)
      end

      def new_user_url
        url_args = [:new, @scope, @office, :user]
        params   = { redirect: @referrer }

        polymorphic_path(url_args.compact, params)
      end

      def suggested_users
        @office.ddfip.users.kept.order(:created_at)
      end
    end
  end
end
