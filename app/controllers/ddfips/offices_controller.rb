# frozen_string_literal: true

module DDFIPs
  class OfficesController < ::OfficesController
    private

    def build_offices_scope
      ddfip = DDFIP.find(params[:ddfip_id])

      authorize! ddfip, to: :show?
      only_kept! ddfip

      @parent  = ddfip
      @offices = ddfip.offices
    end
  end
end
