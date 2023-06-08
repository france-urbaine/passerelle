# frozen_string_literal: true

class AddChangesTriggersToPackages < ActiveRecord::Migration[7.0]
  def change
    create_function :trigger_packages_changes

    create_trigger :trigger_packages_changes, on: :packages
  end
end
