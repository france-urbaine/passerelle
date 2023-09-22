# frozen_string_literal: true

class CreateTransmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :transmissions, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :user,              type: :uuid, null: true, foreign_key: true
      t.references :publisher,         type: :uuid, null: true, foreign_key: true
      t.references :collectivity,      type: :uuid, null: false, foreign_key: true
      t.references :oauth_application, type: :uuid, null: true, foreign_key: true
      t.datetime   :completed_at
      t.boolean    :sandbox, null: false, default: false
      t.timestamps
    end

    change_table :reports do |t|
      t.references :transmission, type: :uuid, null: true, foreign_key: true
    end

    change_table :packages do |t|
      t.references :transmission, type: :uuid, null: true, foreign_key: true
    end
  end
end
