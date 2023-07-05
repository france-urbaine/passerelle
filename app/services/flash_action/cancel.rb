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
      when "destroy"     then url_for(**url_params, action: "undiscard")
      when "destroy_all" then url_for(**url_params, action: "undiscard_all")
      else
        raise NotImplementedError
      end
    end

    def cancel_params
      case @params[:action]
      when "destroy"     then {}
      when "destroy_all" then selection_params
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

    def url_params
      # FIXME: this hack allow to keept parent ID in nested URLs
      # We just fucking need to do something else.
      @params
        .slice(:controller, :publisher_id, :collectivity_id, :ddfip_id, :office_id, :package_id, :id)
        .permit(:controller, :publisher_id, :collectivity_id, :ddfip_id, :office_id, :package_id, :id)
        .to_h
        .symbolize_keys
    end
  end
end
