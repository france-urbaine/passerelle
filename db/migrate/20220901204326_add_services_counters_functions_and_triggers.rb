# frozen_string_literal: true

class AddServicesCountersFunctionsAndTriggers < ActiveRecord::Migration[7.0]
  def change
    create_function :get_services_users_count,    version: 1
    create_function :get_services_communes_count, version: 1
    create_function :reset_all_services_counters, version: 1

    create_function :get_ddfips_services_count, version: 1
    update_function :reset_all_ddfips_counters, version: 3, revert_to_version: 2

    create_function :get_communes_services_count, version: 1
    update_function :reset_all_communes_counters, version: 3, revert_to_version: 2

    create_function :get_users_services_count, version: 1
    create_function :reset_all_users_counters, version: 1

    create_function :trigger_services_changes, version: 1
    create_trigger  :trigger_services_changes, on: :services, version: 1

    create_function :trigger_service_communes_changes, version: 1
    create_trigger  :trigger_service_communes_changes, on: :service_communes, version: 1

    create_function :trigger_user_services_changes, version: 1
    create_trigger  :trigger_user_services_changes, on: :user_services, version: 1

    drop_trigger    :trigger_communes_changes, on: :communes, revert_to_version: 1
    update_function :trigger_communes_changes, version: 3, revert_to_version: 2
    create_trigger  :trigger_communes_changes, on: :communes, version: 1
  end
end
