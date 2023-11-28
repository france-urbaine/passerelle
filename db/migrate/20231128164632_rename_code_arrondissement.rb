# frozen_string_literal: true

class RenameCodeArrondissement < ActiveRecord::Migration[7.0]
  def change
    change_table :communes, bulk: true do |t|
      t.rename  :code_arrondissement, :code_insee_parent
    end

    drop_trigger :trigger_communes_changes, on: :communes, revert_to_version: 1

    update_function :get_communes_arrondissements_count, version: 2, revert_to_version: 1
    update_function :trigger_communes_changes, version: 3, revert_to_version: 2

    create_trigger :trigger_communes_changes, on: :communes, version: 1
  end
end
