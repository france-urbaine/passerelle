# frozen_string_literal: true

module Publishers
  class UsersController < ::UsersController
    private

    def scope_users
      publisher = Publisher.find(params[:publisher_id])

      only_kept! publisher

      @parent = publisher
      @users  = publisher.users
    end
  end
end
