# frozen_string_literal: true

module Collectivities
  class UsersController < ::UsersController
    private

    def scope_users
      collectivity = Collectivity.find(params[:collectivity_id])

      only_kept! collectivity
      only_kept! collectivity.publisher

      @parent = collectivity
      @users  = collectivity.users
    end
  end
end
