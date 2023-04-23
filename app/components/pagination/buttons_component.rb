# frozen_string_literal: true

module Pagination
  class ButtonsComponent < ViewComponent::Base
    attr_reader :pagy, :turbo_frame

    def initialize(pagy, turbo_frame: "_top")
      @pagy        = pagy
      @turbo_frame = turbo_frame
      super()
    end

    def page_url(page)
      new_params = params.slice(:search, :order).permit!
      new_params[:page] = page
      helpers.url_for(new_params)
    end
  end
end
