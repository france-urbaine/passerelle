# frozen_string_literal: true

class CreateUserFormTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_form_types, id: :uuid do |t|
      t.uuid :user_id
      t.enum :form_type, enum_type: :form_type

      t.foreign_key :users, on_delete: :cascade

      t.timestamps
    end
  end
end
