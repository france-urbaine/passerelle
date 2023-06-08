# frozen_string_literal: true

class UpdateFunctionResetAllPublishersCountersToVersion2 < ActiveRecord::Migration[7.0]
  def change
    update_function :reset_all_publishers_counters, version: 2, revert_to_version: 1
  end
end
