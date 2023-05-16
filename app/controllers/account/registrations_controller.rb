# frozen_string_literal: true

module Account
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate_user!

    layout "public"

    def new; end
  end
end
