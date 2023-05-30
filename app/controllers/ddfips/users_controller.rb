# frozen_string_literal: true

module DDFIPs
  class UsersController < ::UsersController
    private

    def build_users_scope
      ddfip = DDFIP.find(params[:ddfip_id])

      authorize! ddfip, to: :show?
      only_kept! ddfip

      @parent = ddfip
      @users  = ddfip.users
    end
  end
end
