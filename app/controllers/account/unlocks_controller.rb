# frozen_string_literal: true

module Account
  class UnlocksController < Devise::UnlocksController
    layout "public"
  end
end
