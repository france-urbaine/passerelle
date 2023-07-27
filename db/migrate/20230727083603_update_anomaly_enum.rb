# frozen_string_literal: true

class UpdateAnomalyEnum < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE anomaly ADD VALUE IF NOT EXISTS 'categorie'"
    execute "ALTER TYPE anomaly RENAME VALUE 'achevement_travaux' TO 'construction_neuve'"
  end

  def down
    execute "ALTER TYPE anomaly RENAME VALUE 'construction_neuve' TO 'achevement_travaux'"
  end
end
