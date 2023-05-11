# frozen_string_literal: true

module Publishers
  class UsersController < ::UsersController
    before_action do
      publisher = Publisher.find(params[:publisher_id])

      next gone(publisher) if publisher.discarded?

      @parent = publisher
      @users_scope = publisher.users
    end
  end
end
