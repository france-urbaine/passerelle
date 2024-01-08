# frozen_string_literal: true

class RemoveUselessFieldsInPackages < ActiveRecord::Migration[7.0]
  def change
    change_table :packages, bulk: true do |t|
      t.remove :name,      type: :string
      t.remove :form_type, type: :enum, enum_type: :form_type
      t.remove :due_on,    type: :date
    end
  end
end
