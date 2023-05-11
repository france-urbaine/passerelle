# frozen_string_literal: true

module DDFIPs
  class OfficesController < ::OfficesController
    before_action do
      ddfip = DDFIP.find(params[:ddfip_id])

      next gone(ddfip) if ddfip&.discarded?

      @parent = ddfip
      @offices_scope = ddfip.offices
    end
  end
end
