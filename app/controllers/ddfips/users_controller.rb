# frozen_string_literal: true

module DDFIPs
  class UsersController < ::UsersController
    before_action do
      ddfip = DDFIP.find(params[:ddfip_id])

      next gone(ddfip) if ddfip&.discarded?

      @parent = ddfip
      @users_scope = ddfip.users
    end
  end
end
