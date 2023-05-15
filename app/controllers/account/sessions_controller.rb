# frozen_string_literal: true

module Account
  class SessionsController < Devise::SessionsController
    layout "public"
  end
end
