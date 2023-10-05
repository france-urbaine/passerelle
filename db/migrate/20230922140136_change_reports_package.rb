# frozen_string_literal: true

class ChangeReportsPackage < ActiveRecord::Migration[7.0]
  def up
    change_table :reports do |t|
      t.change_null :package_id, true
      t.change_null :reference,  true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration if Rails.env.production?

    change_table :reports do |t|
      t.change_null :package_id, false
      t.change_null :reference,  false
    end
  end
end
