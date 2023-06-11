# frozen_string_literal: true

module DDFIPs
  class OfficesController < ::OfficesController
    private

    def load_and_authorize_parent
      ddfip = DDFIP.find(params[:ddfip_id])

      authorize! ddfip, to: :show?
      only_kept! ddfip

      @parent = ddfip
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.offices, as:).strict_loading
    end
  end
end
