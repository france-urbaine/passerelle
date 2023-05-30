# frozen_string_literal: true

module Collectivities
  class UsersController < ::UsersController
    private

    def build_users_scope
      collectivity = Collectivity.find(params[:collectivity_id])

      authorize! collectivity, to: :show?
      only_kept! collectivity
      only_kept! collectivity.publisher

      @parent = collectivity
      @users  = collectivity.users
    end
  end
end
