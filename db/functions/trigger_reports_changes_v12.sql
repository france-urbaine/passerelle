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
    THEN

      UPDATE "packages"
      SET    "reports_count"           = get_packages_reports_count("packages".*),
             "reports_approved_count"  = get_packages_reports_approved_count("packages".*),
             "reports_rejected_count"  = get_packages_reports_rejected_count("packages".*),
             "reports_debated_count"   = get_packages_reports_debated_count("packages".*)
      WHERE  "packages"."id" IN (NEW."package_id", OLD."package_id");

    END IF;

    -- Reset all reports counts in publishers
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "reports_transmitted_count" = get_publishers_reports_transmitted_count("publishers".*),
             "reports_approved_count"    = get_publishers_reports_approved_count("publishers".*),
             "reports_rejected_count"    = get_publishers_reports_rejected_count("publishers".*),
             "reports_debated_count"     = get_publishers_reports_debated_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- Reset all reports counts in collectivities
    -- * on creation
    -- * on deletion
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (completed_at|approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (completed_at|approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."completed_at" IS NULL) <> (OLD."completed_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

       UPDATE "collectivities"
       SET    "reports_incomplete_count"  = get_collectivities_reports_incomplete_count("collectivities".*),
              "reports_packing_count"     = get_collectivities_reports_packing_count("collectivities".*),
              "reports_transmitted_count" = get_collectivities_reports_transmitted_count("collectivities".*),
              "reports_returned_count"    = get_collectivities_reports_returned_count("collectivities".*),
              "reports_pending_count"     = get_collectivities_reports_pending_count("collectivities".*),
              "reports_debated_count"     = get_collectivities_reports_debated_count("collectivities".*),
              "reports_approved_count"    = get_collectivities_reports_approved_count("collectivities".*),
              "reports_rejected_count"    = get_collectivities_reports_rejected_count("collectivities".*)
       WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

    END IF;

    -- Reset all reports & packages counts in ddfips &offices
    -- * on creation
    -- * on deletion
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "ddfips"
      SET    "packages_transmitted_count" = get_ddfips_packages_transmitted_count("ddfips".*),
             "packages_unresolved_count"  = get_ddfips_packages_unresolved_count("ddfips".*),
             "packages_assigned_count"    = get_ddfips_packages_assigned_count("ddfips".*),
             "packages_returned_count"    = get_ddfips_packages_returned_count("ddfips".*),
             "reports_transmitted_count"  = get_ddfips_reports_transmitted_count("ddfips".*),
             "reports_returned_count"     = get_ddfips_reports_returned_count("ddfips".*),
             "reports_pending_count"      = get_ddfips_reports_pending_count("ddfips".*),
             "reports_debated_count"      = get_ddfips_reports_debated_count("ddfips".*),
             "reports_approved_count"     = get_ddfips_reports_approved_count("ddfips".*),
             "reports_rejected_count"     = get_ddfips_reports_rejected_count("ddfips".*)
      WHERE  "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."code_insee" = NEW."code_insee")
         OR  "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."code_insee" = OLD."code_insee" );

      UPDATE "offices"
      SET    "reports_assigned_count" = get_offices_reports_assigned_count("offices".*),
             "reports_pending_count"  = get_offices_reports_pending_count("offices".*),
             "reports_debated_count"  = get_offices_reports_debated_count("offices".*),
             "reports_approved_count" = get_offices_reports_approved_count("offices".*),
             "reports_rejected_count" = get_offices_reports_rejected_count("offices".*)
      WHERE  "offices"."id" IN (SELECT "office_communes"."office_id" FROM "office_communes" WHERE "office_communes"."code_insee" = NEW."code_insee")
         OR  "offices"."id" IN (SELECT "office_communes"."office_id" FROM "office_communes" WHERE "office_communes"."code_insee" = OLD."code_insee");

    END IF;

    -- Reset all reports counts in dgfips
    -- * on creation
    -- * on deletion
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "dgfips"
      SET    "reports_transmitted_count" = get_dgfips_reports_transmitted_count("dgfips".*),
             "reports_returned_count"    = get_dgfips_reports_returned_count("dgfips".*),
             "reports_pending_count"     = get_dgfips_reports_pending_count("dgfips".*),
             "reports_debated_count"     = get_dgfips_reports_debated_count("dgfips".*),
             "reports_approved_count"    = get_dgfips_reports_approved_count("dgfips".*),
             "reports_rejected_count"    = get_dgfips_reports_rejected_count("dgfips".*);

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
