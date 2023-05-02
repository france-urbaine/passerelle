# frozen_string_literal: true

module FlashAction
  class Cancel
    def initialize(params)
      @params = params
    end

    def to_h
      {
        label:  "Annuler",
        method: "patch",
        url:    cancel_path,
        params: cancel_params&.compact || {}
      }
    end

    def to_session
      FlashAction.write(self)
    end

    private

    def cancel_path
      case @params[:action]
      when "destroy"
        url_for(
          action:     "undiscard",
          controller: @params[:controller],
          id:         @params[:id]
        )
      when "destroy_all"
        url_for(
          action:     "undiscard_all",
          controller: @params[:controller]
        )
      else
        raise NotImplementedError
      end
    end

    def cancel_params
      case @params[:action]
      when "destroy"     then { redirect: redirect_path }
      when "destroy_all" then { redirect: redirect_path, **selection_params }
      end
    end

    def url_for(**options)
      Rails.application.routes.url_helpers.url_for(**options, only_path: true)
    end

    def selection_params
      @params
        .slice(:search, :order, :page, :ids)
        .permit(:search, :order, :page, :ids, ids: [])
        .to_h
        .symbolize_keys
    end

    def redirect_path
      @params[:redirect] || default_redirect_path
    end

    def default_redirect_path
      return unless @params[:action] == "destroy_all"

      url_for(
        action:     "index",
        controller: @params[:controller],
        **selection_params.except(:ids)
      )
    end
  end
end
