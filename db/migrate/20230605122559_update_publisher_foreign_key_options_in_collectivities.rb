# frozen_string_literal: true

class UpdatePublisherForeignKeyOptionsInCollectivities < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :collectivities, :publishers
    add_foreign_key    :collectivities, :publishers, on_delete: :nullify
  end
end
