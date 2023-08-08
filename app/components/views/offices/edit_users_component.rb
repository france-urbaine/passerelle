# frozen_string_literal: true

module Views
  module Offices
    class EditUsersComponent < ApplicationViewComponent
      def initialize(office, namespace:, referrer: nil)
        @office    = office
        @namespace = namespace
        @referrer  = referrer
        super()
      end

      def form_url
        polymorphic_path([@namespace, @office, :users].compact)
      end

      def new_user_url
        url_args = [:new, @namespace, @office, :user]
        params   = { redirect: @referrer }

        polymorphic_path(url_args.compact, params)
      end

      def suggested_users
        @office.ddfip.users.kept.order(:created_at)
      end
    end
  end
end
