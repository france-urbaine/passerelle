# frozen_string_literal: true

module ComponentTestHelpers
  module AuthenticationHelpers
    extend ActiveSupport::Concern

    included do
      attr_reader :current_user
    end

    def sign_in(user = create(:user))
      raise ArgumentError, "use an user to sign in" unless user.is_a?(User)

      @current_user = user
      super
    end

    def sign_in_as(...)
      sign_in create(:user, ...)
    end
  end
end
