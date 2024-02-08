CREATE OR REPLACE FUNCTION trigger_reports_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all reports counts in packages
    -- * on creation
    -- * on deletion
    -- * when package_id changed
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."package_id" IS DISTINCT FROM OLD."package_id")
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE "packages"
      SET    "reports_count"           = get_packages_reports_count("packages".*),
             "reports_approved_count"  = get_packages_reports_approved_count("packages".*),
             "reports_rejected_count"  = get_packages_reports_rejected_count("packages".*)
      WHERE  "packages"."id" IN (NEW."package_id", OLD."package_id");

    END IF;

    -- Reset all reports counts in publishers
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|transmitted_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|transmitted_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."transmitted_at" IS NULL) <> (OLD."transmitted_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE "publishers"
      SET    "reports_transmitted_count" = get_publishers_reports_transmitted_count("publishers".*),
             "reports_approved_count"    = get_publishers_reports_approved_count("publishers".*),
             "reports_rejected_count"    = get_publishers_reports_rejected_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- Reset all reports counts in collectivities
    -- * on creation
    -- * on deletion
    -- * when collectivity_id changed
    -- * when collectivity_id changed from NULL
    -- * when collectivity_id changed to NULL
    -- * when (ready_at|approved_at|rejected_at|debated_at|transmitted_at|denied_at|discarded_at) changed to NULL
    -- * when (ready_at|approved_at|rejected_at|debated_at|transmitted_at|denied_at|discarded_at) changed from NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."collectivity_id" IS DISTINCT FROM OLD."collectivity_id")
    OR (TG_OP = 'UPDATE' AND (NEW."ready_at" IS NULL) <> (OLD."ready_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."transmitted_at" IS NULL) <> (OLD."transmitted_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."denied_at" IS NULL) <> (OLD."denied_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

       UPDATE "collectivities"
       SET    "reports_incomplete_count"  = get_collectivities_reports_incomplete_count("collectivities".*),
              "reports_packing_count"     = get_collectivities_reports_packing_count("collectivities".*),
              "reports_transmitted_count" = get_collectivities_reports_transmitted_count("collectivities".*),
              "reports_denied_count"      = get_collectivities_reports_denied_count("collectivities".*),
              "reports_processing_count"  = get_collectivities_reports_processing_count("collectivities".*),
              "reports_approved_count"    = get_collectivities_reports_approved_count("collectivities".*),
              "reports_rejected_count"    = get_collectivities_reports_rejected_count("collectivities".*)
       WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

    END IF;

    -- Reset all reports & packages counts in ddfips &offices
    -- * on creation
    -- * on deletion
    -- * when ddfip_id changed
    -- * when ddfip_id changed from NULL
    -- * when ddfip_id changed to NULL
    -- * when office_id changed
    -- * when office_id changed from NULL
    -- * when office_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|transmitted_at|denied_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|transmitted_at|denied_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."ddfip_id" IS DISTINCT FROM OLD."ddfip_id")
    OR (TG_OP = 'UPDATE' AND NEW."office_id" IS DISTINCT FROM OLD."office_id")
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."transmitted_at" IS NULL) <> (OLD."transmitted_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."denied_at" IS NULL) <> (OLD."denied_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."assigned_at" IS NULL) <> (OLD."assigned_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE "ddfips"
      SET    "reports_transmitted_count"  = get_ddfips_reports_transmitted_count("ddfips".*),
             "reports_denied_count"       = get_ddfips_reports_denied_count("ddfips".*),
             "reports_processing_count"   = get_ddfips_reports_processing_count("ddfips".*),
             "reports_approved_count"     = get_ddfips_reports_approved_count("ddfips".*),
             "reports_rejected_count"     = get_ddfips_reports_rejected_count("ddfips".*)
      WHERE  "ddfips"."id" IN (NEW."ddfip_id", OLD."ddfip_id");

      UPDATE "offices"
      SET    "reports_assigned_count"   = get_offices_reports_assigned_count("offices".*),
             "reports_processing_count" = get_offices_reports_processing_count("offices".*),
             "reports_approved_count"   = get_offices_reports_approved_count("offices".*),
             "reports_rejected_count"   = get_offices_reports_rejected_count("offices".*)
      WHERE  "offices"."id" IN (NEW."office_id", OLD."office_id");
    END IF;

    -- Reset all reports counts in dgfips
    -- * on creation
    -- * on deletion
    -- * when (approved_at|rejected_at|debated_at|transmitted_at|denied_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|transmitted_at|denied_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."transmitted_at" IS NULL) <> (OLD."transmitted_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."denied_at" IS NULL) <> (OLD."denied_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" IS DISTINCT FROM OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND NEW."state" IS DISTINCT FROM OLD."state")
    THEN

      UPDATE "dgfips"
      SET    "reports_transmitted_count" = get_dgfips_reports_transmitted_count("dgfips".*),
             "reports_denied_count"      = get_dgfips_reports_denied_count("dgfips".*),
             "reports_processing_count"  = get_dgfips_reports_processing_count("dgfips".*),
             "reports_approved_count"    = get_dgfips_reports_approved_count("dgfips".*),
             "reports_rejected_count"    = get_dgfips_reports_rejected_count("dgfips".*);

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
