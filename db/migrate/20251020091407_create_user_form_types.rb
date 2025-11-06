# frozen_string_literal: true

class CreateUserFormTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_form_types, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.enum :form_type, enum_type: :form_type, null: false

      t.timestamps
    end
  end
end
