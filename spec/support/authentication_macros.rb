# frozen_string_literal: true

module AuthenticationMacros
  attr_reader :current_user,
    :current_publisher,
    :current_application,
    :current_access_token

  def sign_in(user = create(:user), reload_tracked_fields: false)
    raise ArgumentError, "use an user to sign in" unless user.is_a?(User)

    @current_user = user
    result = super(user)

    if reload_tracked_fields
      # In order to verify updated attributes on user, we have to fire a request
      # and reloading the user:
      # - using `sign_in` setup warden for later request but doesn't touch the user
      # - the first request will update tracked fields (sign_in_count, ..) and the `updated_at`
      # - we expect to verify that the subject request update or not the `updated_at`
      #
      get("/")
      user.reload

      # Because a first request has been fired, implicit `response` and `flash` won't call the subject
      # unless we reset those values:
      @request = @response = nil
      @request_count = 0
    end

    result
  end

  def sign_in_as(...)
    sign_in create(:user, ...)
  end

  def setup_access_token(publisher = nil)
    @current_publisher = publisher || create(:publisher)
    @current_application ||= create(:oauth_application, owner: @current_publisher)

    @current_access_token = create(:doorkeeper_access_token,
      application:       @current_application,
      resource_owner_id: @current_publisher&.id)
  end

  def authorization_header
    @current_access_token ? { "Authorization" => "Bearer #{@current_access_token.token}" } : {}
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers,  type: :component
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include AuthenticationMacros, type: :request
  config.include AuthenticationMacros, type: :component

  config.before(:each, type: :component) do
    @request = vc_test_controller.request
  end
end
