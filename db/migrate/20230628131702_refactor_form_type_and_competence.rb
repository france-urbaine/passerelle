# frozen_string_literal: true

class RefactorFormTypeAndCompetence < ActiveRecord::Migration[7.0]
  def change
    create_enum :form_type, %w[
      evaluation_local_habitation
      evaluation_local_professionnel
      creation_local_habitation
      creation_local_professionnel
      occupation_local_habitation
      occupation_local_professionnel
    ]

    create_enum :anomaly, %w[
      consistance
      affectation
      exoneration
      adresse
      correctif
      omission_batie
      achevement_travaux
      occupation
    ]

    change_table :offices do |t|
      t.rename :action, :competences

      reversible do |dir|
        dir.up do
          t.change :competences, :enum, enum_type: "form_type", array: true, null: false, using: <<~SQL.squish
            CASE
            WHEN "competences"::varchar = 'evaluation_hab' THEN ARRAY['evaluation_local_habitation'::form_type]
            WHEN "competences"::varchar = 'evaluation_pro' THEN ARRAY['evaluation_local_professionnel'::form_type]
            WHEN "competences"::varchar = 'occupation_hab' THEN ARRAY['occupation_local_habitation'::form_type]
            WHEN "competences"::varchar = 'occupation_pro' THEN ARRAY['occupation_local_professionnel'::form_type]
            END
          SQL
        end

        dir.down do
          t.change :action, :enum, enum_type: "action", null: false, using: <<~SQL.squish
            CASE
            WHEN "action" && ARRAY['evaluation_local_habitation'::form_type]    THEN 'evaluation_hab'::action
            WHEN "action" && ARRAY['evaluation_local_professionnel'::form_type] THEN 'evaluation_pro'::action
            WHEN "action" && ARRAY['creation_local_habitation'::form_type]      THEN 'evaluation_hab'::action
            WHEN "action" && ARRAY['creation_local_professionnel'::form_type]   THEN 'evaluation_pro'::action
            WHEN "action" && ARRAY['occupation_local_habitation'::form_type]    THEN 'occupation_hab'::action
            WHEN "action" && ARRAY['occupation_local_professionnel'::form_type] THEN 'occupation_pro'::action
            END
          SQL
        end
      end
    end

    change_table :packages, bulk: true do |t|
      t.rename :action, :form_type

      reversible do |dir|
        dir.up do
          t.change :name, :string, null: true

          t.change :form_type, :enum, enum_type: "form_type", null: false, using: <<~SQL.squish
            CASE
            WHEN "form_type"::varchar = 'evaluation_hab' THEN 'evaluation_local_habitation'::form_type
            WHEN "form_type"::varchar = 'evaluation_pro' THEN 'evaluation_local_professionnel'::form_type
            WHEN "form_type"::varchar = 'occupation_hab' THEN 'occupation_local_habitation'::form_type
            WHEN "form_type"::varchar = 'occupation_pro' THEN 'occupation_local_professionnel'::form_type
            END
          SQL
        end

        dir.down do
          t.change :name, :string, null: false, using: <<~SQL.squish
            COALESCE(name, reference)
          SQL

          t.change :action, :enum, enum_type: "action", null: false, using: <<~SQL.squish
            CASE
            WHEN "action"::varchar = 'evaluation_local_habitation'    THEN 'evaluation_hab'::action
            WHEN "action"::varchar = 'evaluation_local_professionnel' THEN 'evaluation_pro'::action
            WHEN "action"::varchar = 'creation_local_habitation'      THEN 'evaluation_hab'::action
            WHEN "action"::varchar = 'creation_local_professionnel'   THEN 'evaluation_pro'::action
            WHEN "action"::varchar = 'occupation_local_habitation'    THEN 'occupation_hab'::action
            WHEN "action"::varchar = 'occupation_local_professionnel' THEN 'occupation_pro'::action
            END
          SQL
        end
      end
    end

    change_table :reports, bulk: true do |t|
      t.rename :action,  :form_type
      t.rename :subject, :anomalies

      reversible do |dir|
        dir.up do
          t.remove_index name: "index_reports_on_subject_uniqueness"

          t.change :form_type, :enum, enum_type: "form_type", null: false, using: <<~SQL.squish
            CASE
            WHEN "form_type"::varchar = 'evaluation_hab' THEN 'evaluation_local_habitation'::form_type
            WHEN "form_type"::varchar = 'evaluation_pro' THEN 'evaluation_local_professionnel'::form_type
            WHEN "form_type"::varchar = 'occupation_hab' THEN 'occupation_local_habitation'::form_type
            WHEN "form_type"::varchar = 'occupation_pro' THEN 'occupation_local_professionnel'::form_type
            END
          SQL

          t.change :anomalies, :enum, enum_type: "anomaly", array: true, null: false, using: <<~SQL.squish
            CASE
            WHEN "anomalies"::varchar = 'evaluation_hab/evaluation'         THEN ARRAY['consistance'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_hab/exoneration'        THEN ARRAY['exoneration'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_hab/affectation'        THEN ARRAY['affectation'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_hab/adresse'            THEN ARRAY['adresse'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_hab/omission_batie'     THEN ARRAY['omission_batie'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_hab/achevement_travaux' THEN ARRAY['achevement_travaux'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_pro/evaluation'         THEN ARRAY['consistance'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_pro/exoneration'        THEN ARRAY['exoneration'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_pro/affectation'        THEN ARRAY['affectation'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_pro/adresse'            THEN ARRAY['adresse'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_pro/omission_batie'     THEN ARRAY['omission_batie'::anomaly]
            WHEN "anomalies"::varchar = 'evaluation_pro/achevement_travaux' THEN ARRAY['achevement_travaux'::anomaly]
            END
          SQL
        end

        dir.down do
          t.change :action, :enum, enum_type: "action", null: false, using: <<~SQL.squish
            CASE
            WHEN "action"::varchar = 'evaluation_local_habitation'    THEN 'evaluation_hab'::action
            WHEN "action"::varchar = 'evaluation_local_professionnel' THEN 'evaluation_pro'::action
            WHEN "action"::varchar = 'creation_local_habitation'      THEN 'evaluation_hab'::action
            WHEN "action"::varchar = 'creation_local_professionnel'   THEN 'evaluation_pro'::action
            WHEN "action"::varchar = 'occupation_local_habitation'    THEN 'occupation_hab'::action
            WHEN "action"::varchar = 'occupation_local_professionnel' THEN 'occupation_pro'::action
            END
          SQL

          t.change :subject, :string, null: true, using: <<~SQL.squish
            CASE
            WHEN "action"::varchar = 'evaluation_hab' AND "subject" && ARRAY['consistance'::anomaly]        THEN 'evaluation_hab/evaluation'
            WHEN "action"::varchar = 'evaluation_hab' AND "subject" && ARRAY['exoneration'::anomaly]        THEN 'evaluation_hab/exoneration'
            WHEN "action"::varchar = 'evaluation_hab' AND "subject" && ARRAY['affectation'::anomaly]        THEN 'evaluation_hab/affectation'
            WHEN "action"::varchar = 'evaluation_hab' AND "subject" && ARRAY['adresse'::anomaly]            THEN 'evaluation_hab/adresse'
            WHEN "action"::varchar = 'evaluation_hab' AND "subject" && ARRAY['omission_batie'::anomaly]     THEN 'evaluation_hab/omission_batie'
            WHEN "action"::varchar = 'evaluation_hab' AND "subject" && ARRAY['achevement_travaux'::anomaly] THEN 'evaluation_hab/achevement_travaux'
            WHEN "action"::varchar = 'evaluation_pro' AND "subject" && ARRAY['consistance'::anomaly]        THEN 'evaluation_pro/evaluation'
            WHEN "action"::varchar = 'evaluation_pro' AND "subject" && ARRAY['exoneration'::anomaly]        THEN 'evaluation_pro/exoneration'
            WHEN "action"::varchar = 'evaluation_pro' AND "subject" && ARRAY['affectation'::anomaly]        THEN 'evaluation_pro/affectation'
            WHEN "action"::varchar = 'evaluation_pro' AND "subject" && ARRAY['adresse'::anomaly]            THEN 'evaluation_pro/adresse'
            WHEN "action"::varchar = 'evaluation_pro' AND "subject" && ARRAY['omission_batie'::anomaly]     THEN 'evaluation_pro/omission_batie'
            WHEN "action"::varchar = 'evaluation_pro' AND "subject" && ARRAY['achevement_travaux'::anomaly] THEN 'evaluation_pro/achevement_travaux'
            END
          SQL

          t.index %i[sibling_id subject],
            name: "index_reports_on_subject_uniqueness",
            where: "discarded_at IS NULL",
            unique: true
        end
      end
    end

    update_function :get_reports_count_in_offices,          version: 2, revert_to_version: 1
    update_function :get_reports_approved_count_in_offices, version: 2, revert_to_version: 1
    update_function :get_reports_rejected_count_in_offices, version: 2, revert_to_version: 1
    update_function :get_reports_debated_count_in_offices,  version: 2, revert_to_version: 1
  end
end
