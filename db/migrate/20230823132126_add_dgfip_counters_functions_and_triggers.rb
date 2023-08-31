# frozen_string_literal: true

class AddDGFIPCountersFunctionsAndTriggers < ActiveRecord::Migration[7.0]
  def change
    create_function :get_users_count_in_dgfips
    create_function :reset_all_dgfips_counters
    drop_trigger    :trigger_users_changes, on: :users, revert_to_version: 1
    update_function :trigger_users_changes, version: 2, revert_to_version: 1
    create_trigger  :trigger_users_changes, on: :users
  end
end
