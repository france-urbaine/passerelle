# frozen_string_literal: true

class AddDemolitionAnomaly < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        rename_enum :anomaly, to: :old_anomaly
        create_enum :anomaly, %w[
          consistance
          affectation
          categorie
          demolition
          exoneration
          correctif
          omission_batie
          construction_neuve
          occupation
          adresse
        ]

        change_column :reports, :anomalies, :enum,
          array:     true,
          null:      false,
          default:   nil,
          enum_type: :anomaly,
          using:     "anomalies::varchar[]::anomaly[]"

        change_column_default :reports, :anomalies, []
        drop_enum :old_anomaly
      end

      dir.down do
        rename_enum :anomaly, to: :old_anomaly
        create_enum :anomaly, %w[
          consistance
          affectation
          exoneration
          adresse
          correctif
          omission_batie
          construction_neuve
          occupation
          categorie
        ]

        execute "UPDATE reports SET anomalies = array_remove(anomalies, 'demolition'::old_anomaly)"

        change_column :reports, :anomalies, :enum,
          array:     true,
          null:      false,
          default:   nil,
          enum_type: :anomaly,
          using:     "anomalies::varchar[]::anomaly[]"

        change_column_default :reports, :anomalies, []

        drop_enum :old_anomaly
      end
    end

    add_column :reports, :proposition_motif, :string

    say <<~MESSAGE

      !=!=!=!=!=!=!==!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!

          A modification on anomaly type requires you to restart your server.

      !=!=!=!=!=!=!==!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!=!
    MESSAGE
  end
end
