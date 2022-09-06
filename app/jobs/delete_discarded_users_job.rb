# frozen_string_literal: true

class DeleteDiscardedUsersJob < ApplicationJob
  queue_as :default

  def perform(*ids)
    User.discarded.where(id: ids).destroy_all
  end
end
