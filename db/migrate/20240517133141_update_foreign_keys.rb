# frozen_string_literal: true

class UpdateForeignKeys < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :transmissions, :users
    remove_foreign_key :transmissions, :collectivities
    remove_foreign_key :transmissions, :publishers
    remove_foreign_key :transmissions, :oauth_applications

    add_foreign_key :transmissions, :users,              on_delete: :nullify
    add_foreign_key :transmissions, :collectivities,     on_delete: :cascade
    add_foreign_key :transmissions, :publishers,         on_delete: :nullify
    add_foreign_key :transmissions, :oauth_applications, on_delete: :nullify

    remove_foreign_key :reports,  :transmissions
    remove_foreign_key :packages, :transmissions

    add_foreign_key :reports,  :transmissions, on_delete: :nullify
    add_foreign_key :packages, :transmissions, on_delete: :nullify
  end
end
