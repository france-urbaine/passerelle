# frozen_string_literal: true

module Users
  class UnlocksController < Devise::UnlocksController
    layout "public"
  end
end
