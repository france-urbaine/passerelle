# frozen_string_literal: true

module Collectivities
  class UsersController < ::UsersController
    before_action do
      collectivity = Collectivity.find(params[:collectivity_id])

      next gone(collectivity) if collectivity.discarded?
      next gone(collectivity.publisher) if collectivity.publisher.discarded?

      @parent = collectivity
      @users_scope = collectivity.users
    end
  end
end
