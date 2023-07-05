# frozen_string_literal: true

class CreateReportExonerations < ActiveRecord::Migration[7.0]
  def change
    create_enum :exoneration_status, %w[conserver supprimer ajouter]
    create_enum :exoneration_base, %w[imposable impose]
    create_enum :exoneration_code_collectivite, %w[C GC TS OM]

    create_table :report_exonerations, id: :uuid, default: "gen_random_uuid()" do |t|
      t.belongs_to :report, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.string :code,              null: false
      t.string :label,             null: false
      t.enum   :status,            null: false, enum_type: :exoneration_status
      t.enum   :base,              null: false, enum_type: :exoneration_base
      t.enum   :code_collectivite, null: false, enum_type: :exoneration_code_collectivite

      t.timestamps
    end
  end
end
