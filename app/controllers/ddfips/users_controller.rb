# frozen_string_literal: true

module DDFIPs
  class UsersController < ::UsersController
    private

    def scope_users
      ddfip = DDFIP.find(params[:ddfip_id])

      only_kept! ddfip

      @parent = ddfip
      @users  = ddfip.users
    end
  end
end
