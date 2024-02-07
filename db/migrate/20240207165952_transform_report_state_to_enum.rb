# frozen_string_literal: true

class TransformReportStateToEnum < ActiveRecord::Migration[7.1]
  def change
    # Updates all counts on collectivities
    #
    change_table :collectivities, bulk: true do |t|
      t.remove :users_count,               type: :integer, default: 0, null: false
      t.remove :reports_incomplete_count,  type: :integer, default: 0, null: false
      t.remove :reports_packing_count,     type: :integer, default: 0, null: false
      t.remove :reports_transmitted_count, type: :integer, default: 0, null: false
      t.remove :reports_denied_count,      type: :integer, default: 0, null: false
      t.remove :reports_processing_count,  type: :integer, default: 0, null: false
      t.remove :reports_approved_count,    type: :integer, default: 0, null: false
      t.remove :reports_rejected_count,    type: :integer, default: 0, null: false
    end

    change_table :collectivities, bulk: true do |t|
      t.integer :users_count,               default: 0, null: false
      t.integer :reports_transmitted_count, default: 0, null: false
      t.integer :reports_accepted_count,    default: 0, null: false
      t.integer :reports_rejected_count,    default: 0, null: false
      t.integer :reports_approved_count,    default: 0, null: false
      t.integer :reports_canceled_count,    default: 0, null: false
      t.integer :reports_returned_count,    default: 0, null: false

      up_only do
        t.check_constraint "users_count >= 0",               name: "users_count_check"
        t.check_constraint "reports_transmitted_count >= 0", name: "reports_transmitted_count_check"
        t.check_constraint "reports_accepted_count >= 0",    name: "reports_accepted_count_check"
        t.check_constraint "reports_rejected_count >= 0",    name: "reports_rejected_count_check"
        t.check_constraint "reports_approved_count >= 0",    name: "reports_approved_count_check"
        t.check_constraint "reports_canceled_count >= 0",    name: "reports_canceled_count_check"
        t.check_constraint "reports_returned_count >= 0",    name: "reports_returned_count_check"
      end
    end

    drop_function :reset_all_collectivities_counters,            revert_to_version: 1
    drop_function :get_collectivities_reports_incomplete_count,  revert_to_version: 1
    drop_function :get_collectivities_reports_packing_count,     revert_to_version: 1
    drop_function :get_collectivities_reports_transmitted_count, revert_to_version: 1
    drop_function :get_collectivities_reports_denied_count,      revert_to_version: 1
    drop_function :get_collectivities_reports_processing_count,  revert_to_version: 1
    drop_function :get_collectivities_reports_approved_count,    revert_to_version: 1
    drop_function :get_collectivities_reports_rejected_count,    revert_to_version: 1

    create_function :get_collectivities_reports_transmitted_count, version: 2
    create_function :get_collectivities_reports_accepted_count,    version: 2
    create_function :get_collectivities_reports_rejected_count,    version: 2
    create_function :get_collectivities_reports_approved_count,    version: 2
    create_function :get_collectivities_reports_canceled_count,    version: 2
    create_function :get_collectivities_reports_returned_count,    version: 2
    create_function :reset_all_collectivities_counters,            version: 2

    # Updates all counts on ddfips
    #
    change_table :ddfips, bulk: true do |t|
      t.remove :users_count,               type: :integer, default: 0, null: false
      t.remove :collectivities_count,      type: :integer, default: 0, null: false
      t.remove :offices_count,             type: :integer, default: 0, null: false
      t.remove :reports_transmitted_count, type: :integer, default: 0, null: false
      t.remove :reports_denied_count,      type: :integer, default: 0, null: false
      t.remove :reports_processing_count,  type: :integer, default: 0, null: false
      t.remove :reports_approved_count,    type: :integer, default: 0, null: false
      t.remove :reports_rejected_count,    type: :integer, default: 0, null: false
    end

    change_table :ddfips, bulk: true do |t|
      t.integer :users_count,               default: 0, null: false
      t.integer :collectivities_count,      default: 0, null: false
      t.integer :offices_count,             default: 0, null: false
      t.integer :reports_transmitted_count, default: 0, null: false
      t.integer :reports_unassigned_count,  default: 0, null: false
      t.integer :reports_accepted_count,    default: 0, null: false
      t.integer :reports_rejected_count,    default: 0, null: false
      t.integer :reports_approved_count,    default: 0, null: false
      t.integer :reports_canceled_count,    default: 0, null: false
      t.integer :reports_returned_count,    default: 0, null: false

      up_only do
        t.check_constraint "users_count >= 0",               name: "users_count_check"
        t.check_constraint "collectivities_count >= 0",      name: "collectivities_count_check"
        t.check_constraint "offices_count >= 0",             name: "offices_count_check"
        t.check_constraint "reports_transmitted_count >= 0", name: "reports_transmitted_count_check"
        t.check_constraint "reports_unassigned_count >= 0", name: "reports_unassigned_count_check"
        t.check_constraint "reports_accepted_count >= 0",    name: "reports_accepted_count_check"
        t.check_constraint "reports_rejected_count >= 0",    name: "reports_rejected_count_check"
        t.check_constraint "reports_approved_count >= 0",    name: "reports_approved_count_check"
        t.check_constraint "reports_returned_count >= 0",    name: "reports_returned_count_check"
      end
    end

    drop_function :reset_all_ddfips_counters,            revert_to_version: 1
    drop_function :get_ddfips_reports_transmitted_count, revert_to_version: 1
    drop_function :get_ddfips_reports_denied_count,      revert_to_version: 1
    drop_function :get_ddfips_reports_processing_count,  revert_to_version: 1
    drop_function :get_ddfips_reports_approved_count,    revert_to_version: 1
    drop_function :get_ddfips_reports_rejected_count,    revert_to_version: 1

    create_function :get_ddfips_reports_transmitted_count, version: 2
    create_function :get_ddfips_reports_unassigned_count,  version: 2
    create_function :get_ddfips_reports_accepted_count,    version: 2
    create_function :get_ddfips_reports_rejected_count,    version: 2
    create_function :get_ddfips_reports_approved_count,    version: 2
    create_function :get_ddfips_reports_canceled_count,    version: 2
    create_function :get_ddfips_reports_returned_count,    version: 2
    create_function :reset_all_ddfips_counters,            version: 2

    # Updates all counts on dgfips
    #
    change_table :dgfips, bulk: true do |t|
      t.remove :users_count,               type: :integer, default: 0, null: false
      t.remove :reports_transmitted_count, type: :integer, default: 0, null: false
      t.remove :reports_denied_count,      type: :integer, default: 0, null: false
      t.remove :reports_processing_count,  type: :integer, default: 0, null: false
      t.remove :reports_approved_count,    type: :integer, default: 0, null: false
      t.remove :reports_rejected_count,    type: :integer, default: 0, null: false
    end

    change_table :dgfips, bulk: true do |t|
      t.integer :users_count,               default: 0, null: false
      t.integer :reports_transmitted_count, default: 0, null: false
      t.integer :reports_accepted_count,    default: 0, null: false
      t.integer :reports_rejected_count,    default: 0, null: false
      t.integer :reports_approved_count,    default: 0, null: false
      t.integer :reports_canceled_count,    default: 0, null: false

      up_only do
        t.check_constraint "users_count >= 0",               name: "users_count_check"
        t.check_constraint "reports_transmitted_count >= 0", name: "reports_transmitted_count_check"
        t.check_constraint "reports_accepted_count >= 0",    name: "reports_accepted_count_check"
        t.check_constraint "reports_rejected_count >= 0",    name: "reports_rejected_count_check"
        t.check_constraint "reports_approved_count >= 0",    name: "reports_approved_count_check"
        t.check_constraint "reports_canceled_count >= 0",    name: "reports_canceled_count_check"
      end
    end

    drop_function :reset_all_dgfips_counters,            revert_to_version: 1
    drop_function :get_dgfips_reports_transmitted_count, revert_to_version: 1
    drop_function :get_dgfips_reports_denied_count,      revert_to_version: 1
    drop_function :get_dgfips_reports_processing_count,  revert_to_version: 1
    drop_function :get_dgfips_reports_approved_count,    revert_to_version: 1
    drop_function :get_dgfips_reports_rejected_count,    revert_to_version: 1

    create_function :get_dgfips_reports_transmitted_count, version: 2
    create_function :get_dgfips_reports_accepted_count,    version: 2
    create_function :get_dgfips_reports_rejected_count,    version: 2
    create_function :get_dgfips_reports_approved_count,    version: 2
    create_function :get_dgfips_reports_canceled_count,    version: 2
    create_function :reset_all_dgfips_counters,            version: 2

    # Updates all counts on offices
    #
    change_table :offices, bulk: true do |t|
      t.remove :users_count,              type: :integer, default: 0, null: false
      t.remove :communes_count,           type: :integer, default: 0, null: false
      t.remove :reports_assigned_count,   type: :integer, default: 0, null: false
      t.remove :reports_processing_count, type: :integer, default: 0, null: false
      t.remove :reports_approved_count,   type: :integer, default: 0, null: false
      t.remove :reports_rejected_count,   type: :integer, default: 0, null: false
    end

    change_table :offices, bulk: true do |t|
      t.integer :users_count,               default: 0, null: false
      t.integer :communes_count,            default: 0, null: false
      t.integer :reports_assigned_count,    default: 0, null: false
      t.integer :reports_resolved_count,    default: 0, null: false
      t.integer :reports_approved_count,    default: 0, null: false
      t.integer :reports_canceled_count,    default: 0, null: false

      up_only do
        t.check_constraint "users_count >= 0",            name: "users_count_check"
        t.check_constraint "communes_count >= 0",         name: "communes_count_check"
        t.check_constraint "reports_assigned_count >= 0", name: "reports_assigned_count_check"
        t.check_constraint "reports_resolved_count >= 0", name: "reports_resolved_count_check"
        t.check_constraint "reports_approved_count >= 0", name: "reports_approved_count_check"
        t.check_constraint "reports_canceled_count >= 0", name: "reports_canceled_count_check"
      end
    end

    drop_function :reset_all_offices_counters,           revert_to_version: 1
    drop_function :get_offices_reports_assigned_count,   revert_to_version: 1
    drop_function :get_offices_reports_processing_count, revert_to_version: 1
    drop_function :get_offices_reports_approved_count,   revert_to_version: 1
    drop_function :get_offices_reports_rejected_count,   revert_to_version: 1

    create_function :get_offices_reports_assigned_count, version: 2
    create_function :get_offices_reports_resolved_count, version: 2
    create_function :get_offices_reports_approved_count, version: 2
    create_function :get_offices_reports_canceled_count, version: 2
    create_function :reset_all_offices_counters,         version: 2

    # Updates all counts on packages
    #
    change_table :packages, bulk: true do |t|
      t.remove :reports_count,          type: :integer, default: 0, null: false
      t.remove :reports_approved_count, type: :integer, default: 0, null: false
      t.remove :reports_rejected_count, type: :integer, default: 0, null: false
    end

    change_table :packages, bulk: true do |t|
      t.integer :reports_count,          default: 0, null: false
      t.integer :reports_accepted_count, default: 0, null: false
      t.integer :reports_rejected_count, default: 0, null: false
      t.integer :reports_approved_count, default: 0, null: false
      t.integer :reports_canceled_count, default: 0, null: false

      up_only do
        t.check_constraint "reports_count >= 0",          name: "reports_count_check"
        t.check_constraint "reports_accepted_count >= 0", name: "reports_accepted_count_check"
        t.check_constraint "reports_rejected_count >= 0", name: "reports_rejected_count_check"
        t.check_constraint "reports_approved_count >= 0", name: "reports_approved_count_check"
        t.check_constraint "reports_canceled_count >= 0", name: "reports_canceled_count_check"
      end
    end

    drop_function :reset_all_packages_counters,         revert_to_version: 1
    drop_function :get_packages_reports_count,          revert_to_version: 1
    drop_function :get_packages_reports_approved_count, revert_to_version: 1
    drop_function :get_packages_reports_rejected_count, revert_to_version: 1

    create_function :get_packages_reports_count,          version: 2
    create_function :get_packages_reports_accepted_count, version: 2
    create_function :get_packages_reports_rejected_count, version: 2
    create_function :get_packages_reports_approved_count, version: 2
    create_function :get_packages_reports_canceled_count, version: 2
    create_function :reset_all_packages_counters,         version: 2

    # Updates all counts on publishers
    #
    change_table :publishers, bulk: true do |t|
      t.remove :users_count,               type: :integer, default: 0, null: false
      t.remove :collectivities_count,      type: :integer, default: 0, null: false
      t.remove :reports_transmitted_count, type: :integer, default: 0, null: false
      t.remove :reports_approved_count,    type: :integer, default: 0, null: false
      t.remove :reports_rejected_count,    type: :integer, default: 0, null: false
    end

    change_table :publishers, bulk: true do |t|
      t.integer :users_count,               default: 0, null: false
      t.integer :collectivities_count,      default: 0, null: false
      t.integer :reports_transmitted_count, default: 0, null: false
      t.integer :reports_accepted_count,    default: 0, null: false
      t.integer :reports_rejected_count,    default: 0, null: false
      t.integer :reports_approved_count,    default: 0, null: false
      t.integer :reports_canceled_count,    default: 0, null: false
      t.integer :reports_returned_count,    default: 0, null: false

      up_only do
        t.check_constraint "users_count >= 0",               name: "users_count_check"
        t.check_constraint "collectivities_count >= 0",      name: "collectivities_count_check"
        t.check_constraint "reports_transmitted_count >= 0", name: "reports_transmitted_count_check"
        t.check_constraint "reports_accepted_count >= 0",    name: "reports_accepted_count_check"
        t.check_constraint "reports_rejected_count >= 0",    name: "reports_rejected_count_check"
        t.check_constraint "reports_approved_count >= 0",    name: "reports_approved_count_check"
        t.check_constraint "reports_canceled_count >= 0",    name: "reports_canceled_count_check"
        t.check_constraint "reports_returned_count >= 0",    name: "reports_returned_count_check"
      end
    end

    drop_function :reset_all_publishers_counters,            revert_to_version: 1
    drop_function :get_publishers_reports_transmitted_count, revert_to_version: 1
    drop_function :get_publishers_reports_approved_count,    revert_to_version: 1
    drop_function :get_publishers_reports_rejected_count,    revert_to_version: 1

    create_function :get_publishers_reports_transmitted_count, version: 2
    create_function :get_publishers_reports_accepted_count,    version: 2
    create_function :get_publishers_reports_rejected_count,    version: 2
    create_function :get_publishers_reports_approved_count,    version: 2
    create_function :get_publishers_reports_canceled_count,    version: 2
    create_function :get_publishers_reports_returned_count,    version: 2
    create_function :reset_all_publishers_counters,            version: 2

    # Updates triggers
    #
    drop_trigger :trigger_office_communes_changes, revert_to_version: 1, on: :office_communes
    drop_trigger :trigger_packages_changes,        revert_to_version: 1, on: :packages
    drop_trigger :trigger_reports_changes,         revert_to_version: 1, on: :reports

    drop_function :trigger_office_communes_changes, revert_to_version: 1
    drop_function :trigger_packages_changes,        revert_to_version: 1
    drop_function :trigger_reports_changes,         revert_to_version: 1

    create_function :trigger_office_communes_changes, version: 2
    create_function :trigger_reports_changes,         version: 2

    create_trigger :trigger_office_communes_changes, version: 1, on: :office_communes
    create_trigger :trigger_reports_changes,         version: 1, on: :reports

    # Updates report state
    #
    create_enum :report_state, %w[
      draft
      ready
      transmitted
      acknowledged
      accepted
      assigned
      applicable
      inapplicable
      approved
      canceled
      rejected
    ]

    change_table :reports do |t|
      t.rename :state, :old_state
      t.enum   :state, enum_type: "report_state", default: "draft", null: false
      t.index  :state
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE reports
          SET    state =
            CASE old_state
              WHEN 'draft'        THEN 'draft'::report_state
              WHEN 'ready'        THEN 'ready'::report_state
              WHEN 'sent'         THEN 'transmitted'::report_state
              WHEN 'acknowledged' THEN 'acknowledged'::report_state
              WHEN 'denied'       THEN 'rejected'::report_state
              WHEN 'processing'   THEN 'assigned'::report_state
              WHEN 'approved'     THEN 'applicable'::report_state
              WHEN 'rejected'     THEN 'inapplicable'::report_state
            END
        SQL

        remove_column :reports, :old_state
      end

      dir.down do
        add_column :reports, :old_state, :string, default: "draft"
        add_index  :reports, :old_state

        execute <<~SQL.squish
          UPDATE reports
          SET    old_state =
            CASE state::text
              WHEN 'draft'          THEN 'draft'
              WHEN 'ready'          THEN 'ready'
              WHEN 'transmitted'    THEN 'sent'
              WHEN 'acknowledged'   THEN 'acknowledged'
              WHEN 'accepted'       THEN 'processing'
              WHEN 'assigned'       THEN 'processing'
              WHEN 'applicable'     THEN 'approved'
              WHEN 'inapplicable'   THEN 'rejected'
              WHEN 'approved'       THEN 'approved'
              WHEN 'canceled'       THEN 'rejected'
              WHEN 'rejected'       THEN 'denied'
              ELSE state::text
            END
        SQL
      end
    end

    # Updates report datetime
    #
    change_table :reports, bulk: true do |t|
      t.rename :approved_at,     :old_approved_at
      t.rename :rejected_at,     :old_rejected_at
      t.rename :ready_at,        :old_ready_at
      t.rename :transmitted_at,  :old_transmitted_at
      t.rename :assigned_at,     :old_assigned_at
      t.rename :denied_at,       :old_denied_at
      t.rename :acknowledged_at, :old_acknowledged_at
    end

    change_table :reports, bulk: true do |t|
      t.datetime :completed_at
      t.datetime :transmitted_at
      t.datetime :acknowledged_at
      t.datetime :accepted_at
      t.datetime :assigned_at
      t.datetime :resolved_at
      t.datetime :returned_at
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE reports
          SET    completed_at    = old_ready_at,
                 transmitted_at  = old_transmitted_at,
                 acknowledged_at = old_acknowledged_at,
                 accepted_at     = old_assigned_at,
                 assigned_at     = old_assigned_at,
                 resolved_at     = COALESCE(old_approved_at, old_rejected_at),
                 returned_at     = old_denied_at
        SQL
      end

      dir.down do
        execute <<~SQL.squish
          UPDATE reports
          SET    old_ready_at        = completed_at,
                 old_transmitted_at  = transmitted_at,
                 old_assigned_at     = assigned_at,
                 old_acknowledged_at = acknowledged_at
        SQL

        execute <<~SQL.squish
          UPDATE reports
          SET    old_approved_at = resolved_at
          WHERE  state IN ('applicable', 'approved')
        SQL

        execute <<~SQL.squish
          UPDATE reports
          SET    old_rejected_at = resolved_at
          WHERE  state IN ('inapplicable', 'canceled')
        SQL

        execute <<~SQL.squish
          UPDATE reports
          SET    old_denied_at = returned_at
          WHERE  state = 'rejected'
        SQL
      end
    end

    change_table :reports, bulk: true do |t|
      t.remove :old_approved_at,      type: :datetime
      t.remove :old_rejected_at,      type: :datetime
      t.remove :debated_at,           type: :datetime
      t.remove :old_ready_at,         type: :datetime
      t.remove :old_transmitted_at,   type: :datetime
      t.remove :old_assigned_at,      type: :datetime
      t.remove :old_denied_at,        type: :datetime
      t.remove :old_acknowledged_at,  type: :datetime
    end

    up_only do
      execute "SELECT reset_all_collectivities_counters()"
      execute "SELECT reset_all_ddfips_counters()"
      execute "SELECT reset_all_dgfips_counters()"
      execute "SELECT reset_all_offices_counters()"
      execute "SELECT reset_all_packages_counters()"
      execute "SELECT reset_all_publishers_counters()"
    end
  end
end
