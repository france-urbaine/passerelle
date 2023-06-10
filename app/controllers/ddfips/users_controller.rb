# frozen_string_literal: true

module DDFIPs
  class UsersController < ::UsersController
    private

    def load_and_authorize_parent
      ddfip = DDFIP.find(params[:ddfip_id])

      authorize! ddfip, to: :show?
      only_kept! ddfip

      @parent = ddfip
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.users, as:).strict_loading
    end
  end
end
