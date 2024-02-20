# frozen_string_literal: true

class AddAdressComputationToReports < ActiveRecord::Migration[7.1]
  def change
    change_table :reports, bulk: true do |t|
      t.string :computed_address
      t.string :computed_address_sort_key
    end

    up_only do
      Report.find_each(&:save)
    end
  end
end
