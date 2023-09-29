# frozen_string_literal: true

class AddSandboxToReports < ActiveRecord::Migration[7.0]
  def change
    change_table :reports do |t|
      t.boolean :sandbox, null: false, default: false
    end
  end
end
