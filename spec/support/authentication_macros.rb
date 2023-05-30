# frozen_string_literal: true

module AuthenticationMacros
  attr_reader :current_user

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
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include AuthenticationMacros, type: :request
end
