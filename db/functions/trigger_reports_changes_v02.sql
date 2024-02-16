CREATE OR REPLACE FUNCTION trigger_reports_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all reports counts in packages
    -- * on creation
    -- * on deletion
    -- * when package_id changed
    -- * when discarded_at changed from/to NULL
    -- * when sandbox changed
    -- * when state changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."package_id" IS DISTINCT FROM OLD."package_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE  "packages"
      SET     "reports_count"          = get_packages_reports_count("packages".*),
              "reports_accepted_count" = get_packages_reports_accepted_count("packages".*),
              "reports_rejected_count" = get_packages_reports_rejected_count("packages".*),
              "reports_approved_count" = get_packages_reports_approved_count("packages".*),
              "reports_canceled_count" = get_packages_reports_canceled_count("packages".*)
      WHERE   "packages"."id" IN (NEW."package_id", OLD."package_id");

    END IF;

    -- Reset all reports counts in publishers
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when discarded_at changed from/to NULL
    -- * when sandbox changed
    -- * when state changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE  "publishers"
      SET     "reports_transmitted_count"  = get_publishers_reports_transmitted_count("publishers".*),
              "reports_accepted_count"     = get_publishers_reports_accepted_count("publishers".*),
              "reports_rejected_count"     = get_publishers_reports_rejected_count("publishers".*),
              "reports_approved_count"     = get_publishers_reports_approved_count("publishers".*),
              "reports_canceled_count"     = get_publishers_reports_canceled_count("publishers".*),
              "reports_returned_count"     = get_publishers_reports_returned_count("publishers".*)
      WHERE   "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- Reset all reports counts in collectivities
    -- * on creation
    -- * on deletion
    -- * when collectivity_id changed
    -- * when discarded_at changed from/to NULL
    -- * when sandbox changed
    -- * when state changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."collectivity_id" IS DISTINCT FROM OLD."collectivity_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE  "collectivities"
      SET     "reports_transmitted_count"  = get_collectivities_reports_transmitted_count("collectivities".*),
              "reports_accepted_count"     = get_collectivities_reports_accepted_count("collectivities".*),
              "reports_rejected_count"     = get_collectivities_reports_rejected_count("collectivities".*),
              "reports_approved_count"     = get_collectivities_reports_approved_count("collectivities".*),
              "reports_canceled_count"     = get_collectivities_reports_canceled_count("collectivities".*),
              "reports_returned_count"     = get_collectivities_reports_returned_count("collectivities".*)
      WHERE   "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

    END IF;

    -- Reset all reports in ddfips
    -- * on creation
    -- * on deletion
    -- * when ddfip_id changed
    -- * when discarded_at changed from/to NULL
    -- * when sandbox changed
    -- * when state changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."ddfip_id" IS DISTINCT FROM OLD."ddfip_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE  "ddfips"
      SET     "reports_transmitted_count" = get_ddfips_reports_transmitted_count("ddfips".*),
              "reports_unassigned_count" = get_ddfips_reports_unassigned_count("ddfips".*),
              "reports_accepted_count"    = get_ddfips_reports_accepted_count("ddfips".*),
              "reports_rejected_count"    = get_ddfips_reports_rejected_count("ddfips".*),
              "reports_approved_count"    = get_ddfips_reports_approved_count("ddfips".*),
              "reports_canceled_count"    = get_ddfips_reports_canceled_count("ddfips".*),
              "reports_returned_count"    = get_ddfips_reports_returned_count("ddfips".*)
      WHERE   "ddfips"."id" IN (NEW."ddfip_id", OLD."ddfip_id");

    END IF;

    -- Reset all reports in offices
    -- * on creation
    -- * on deletion
    -- * when office_id changed
    -- * when discarded_at changed from/to NULL
    -- * when sandbox changed
    -- * when state changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."office_id" IS DISTINCT FROM OLD."office_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE  "offices"
      SET     "reports_assigned_count"   = get_offices_reports_assigned_count("offices".*),
              "reports_resolved_count"   = get_offices_reports_resolved_count("offices".*),
              "reports_approved_count"   = get_offices_reports_approved_count("offices".*),
              "reports_canceled_count"   = get_offices_reports_canceled_count("offices".*)
      WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");
    END IF;

    -- Reset all reports counts in dgfips
    -- * on creation
    -- * on deletion
    -- * when discarded_at changed from/to NULL
    -- * when sandbox changed
    -- * when state changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE  "dgfips"
      SET     "reports_transmitted_count"  = get_dgfips_reports_transmitted_count("dgfips".*),
              "reports_accepted_count"     = get_dgfips_reports_accepted_count("dgfips".*),
              "reports_rejected_count"     = get_dgfips_reports_rejected_count("dgfips".*),
              "reports_approved_count"     = get_dgfips_reports_approved_count("dgfips".*),
              "reports_canceled_count"     = get_dgfips_reports_canceled_count("dgfips".*);

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
