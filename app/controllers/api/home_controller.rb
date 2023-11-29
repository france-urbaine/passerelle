# frozen_string_literal: true

module API
  class HomeController < ApplicationController
    skip_before_action :doorkeeper_authorize!

    def index
      head :no_content
    end
  end
end
