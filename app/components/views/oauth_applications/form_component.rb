# frozen_string_literal: true

module Views
  module OauthApplications
    class FormComponent < ApplicationViewComponent
      def initialize(oauth_application, namespace:, referrer: nil)
        @oauth_application = oauth_application
        @namespace         = namespace
        @referrer          = referrer
        super()
      end

      def form_url
        url_args = [@namespace]

        if @oauth_application.new_record?
          url_args << @ddfip
          url_args << :oauth_applications
        else
          url_args << @oauth_application
        end

        polymorphic_path(url_args.compact)
      end

      def redirection_path
        if @referrer.nil? && @oauth_application.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end
    end
  end
end
