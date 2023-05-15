# frozen_string_literal: true

module Account
  class ConfirmationsController < Devise::ConfirmationsController
    layout "public"
  end
end
