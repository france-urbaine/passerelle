# frozen_string_literal: true

class AddSoftDeletionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :discarded_at, :datetime
    add_index  :users, :discarded_at

    update_function :get_collectivities_users_count, version: 3, revert_to_version: 2
    update_function :get_ddfips_users_count,         version: 3, revert_to_version: 2
    update_function :get_publishers_users_count,     version: 3, revert_to_version: 2
    update_function :get_services_users_count,       version: 2, revert_to_version: 1

    drop_trigger    :trigger_users_changes, on: :users, revert_to_version: 1
    update_function :trigger_users_changes, version: 3, revert_to_version: 2
    create_trigger  :trigger_users_changes, on: :users, version: 1
  end
end
