# frozen_string_literal: true

module Publishers
  class UsersController < ::UsersController
    private

    def build_users_scope
      publisher = Publisher.find(params[:publisher_id])

      authorize! publisher, to: :show?
      only_kept! publisher

      @parent = publisher
      @users  = publisher.users
    end
  end
end
