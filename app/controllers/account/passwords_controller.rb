# frozen_string_literal: true

module Account
  class PasswordsController < Devise::PasswordsController
    layout "public"
  end
end
