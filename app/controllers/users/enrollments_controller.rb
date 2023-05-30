# frozen_string_literal: true

module Users
  class EnrollmentsController < ApplicationController
    prepend_before_action :sign_out
    skip_before_action :authenticate_user!

    layout "public"

    def new; end
  end
end
