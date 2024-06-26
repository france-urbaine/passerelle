# frozen_string_literal: true

module RequestTestHelpers
  module AuthenticationHelpers
    extend ActiveSupport::Concern

    included do
      attr_reader :current_user,
        :current_publisher,
        :current_application,
        :current_access_token
    end

    def sign_in(user = create(:user), reload_tracked_fields: false)
      raise ArgumentError, "use an user to sign in" unless user.is_a?(User)

      @current_user = user
      result = super(user)

      if reload_tracked_fields
        # In order to verify updated attributes on the given user after any request,
        # we first need to fire a request and reloading the user:
        #
        #   * using the `sign_in` method is preparing warden for further request but doesn't touch the user
        #   * the first request will update all tracked fields (updated_at, sign_in_count, last_sign_in_at ...)
        #
        get("/")
        user.reload

        # Because a first request has been fired, implicit helpers (see ./implicit_helpers.rb) won't call
        # the expected subject request.
        # We also need to reset those values:
        #
        @request = @response = nil
        @request_count = 0
      end

      result
    end

    def sign_in_as(...)
      sign_in create(:user, ...)
    end

    def setup_access_token(publisher = nil, oauth_application = nil)
      @current_publisher   = publisher || create(:publisher)
      @current_application = oauth_application || create(:oauth_application, owner: @current_publisher)

      @current_access_token = create(:doorkeeper_access_token,
        application:       @current_application,
        resource_owner_id: @current_publisher&.id)
    end

    def authorization_header
      @current_access_token ? { "Authorization" => "Bearer #{@current_access_token.token}" } : {}
    end
  end
end
