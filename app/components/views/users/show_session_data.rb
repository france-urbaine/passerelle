# frozen_string_literal: true

module Views
  module Users
    class ShowSessionData < ApplicationViewComponent
      def initialize(user)
        @user = user
        super()
      end
    end
  end
end
