# frozen_string_literal: true

class UpdateDoorkeeperOwnerType < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :oauth_access_grants, :users, column: :resource_owner_id
    remove_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id

    add_foreign_key :oauth_access_grants, :publishers, column: :resource_owner_id, on_delete: :cascade
    add_foreign_key :oauth_access_tokens, :publishers, column: :resource_owner_id, on_delete: :cascade
  end
end
