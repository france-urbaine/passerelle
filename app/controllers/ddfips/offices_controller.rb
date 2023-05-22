# frozen_string_literal: true

module DDFIPs
  class OfficesController < ::OfficesController
    private

    def scope_offices
      ddfip = DDFIP.find(params[:ddfip_id])

      only_kept! ddfip

      @parent  = ddfip
      @offices = ddfip.offices
    end

    def office_params
      super().except(:ddfip_id)
    end
  end
end
