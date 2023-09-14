CREATE OR REPLACE FUNCTION trigger_reports_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all reports counts on packages
    -- * on creation
    -- * on deletion
    -- * when package_id changed
    -- * when completed changed
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."package_id" <> OLD."package_id")
    OR (TG_OP = 'UPDATE' AND NEW."completed_at" IS DISTINCT FROM OLD."completed_at")
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "packages"
      SET    "reports_count"           = get_reports_count_in_packages("packages".*),
             "reports_completed_count" = get_reports_completed_count_in_packages("packages".*),
             "reports_approved_count"  = get_reports_approved_count_in_packages("packages".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_packages("packages".*),
             "reports_debated_count"   = get_reports_debated_count_in_packages("packages".*)
      WHERE  "packages"."id" IN (NEW."package_id", OLD."package_id");

    END IF;

    -- Reset all reports counts on publishers, collectivities, ddfips, dgfips & offices
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND ((NEW."publisher_id" IS NULL) <> (OLD."publisher_id" IS NULL) OR (NEW."publisher_id" <> OLD."publisher_id")))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "reports_transmitted_count" = get_reports_transmitted_count_in_publishers("publishers".*),
             "reports_approved_count"    = get_reports_approved_count_in_publishers("publishers".*),
             "reports_rejected_count"    = get_reports_rejected_count_in_publishers("publishers".*),
             "reports_debated_count"     = get_reports_debated_count_in_publishers("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

      UPDATE "collectivities"
      SET    "reports_transmitted_count" = get_reports_transmitted_count_in_collectivities("collectivities".*),
             "reports_approved_count"    = get_reports_approved_count_in_collectivities("collectivities".*),
             "reports_rejected_count"    = get_reports_rejected_count_in_collectivities("collectivities".*),
             "reports_debated_count"     = get_reports_debated_count_in_collectivities("collectivities".*),
             "reports_packing_count"     = get_reports_packing_count_in_collectivities("collectivities".*)
      WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

      UPDATE "ddfips"
      SET    "reports_count"          = get_reports_count_in_ddfips("ddfips".*),
             "reports_approved_count" = get_reports_approved_count_in_ddfips("ddfips".*),
             "reports_rejected_count" = get_reports_rejected_count_in_ddfips("ddfips".*),
             "reports_debated_count"  = get_reports_debated_count_in_ddfips("ddfips".*),
             "reports_pending_count"  = get_reports_pending_count_in_ddfips("ddfips".*)
      WHERE  "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."code_insee" = NEW."code_insee")
         OR  "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."code_insee" = OLD."code_insee" );

      UPDATE "dgfips"
      SET    "reports_delivered_count" = get_reports_delivered_count_in_dgfips("dgfips".*),
             "reports_approved_count"  = get_reports_approved_count_in_dgfips("dgfips".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_dgfips("dgfips".*);

      UPDATE "offices"
      SET    "reports_count"          = get_reports_count_in_offices("offices".*),
             "reports_approved_count" = get_reports_approved_count_in_offices("offices".*),
             "reports_rejected_count" = get_reports_rejected_count_in_offices("offices".*),
             "reports_debated_count"  = get_reports_debated_count_in_offices("offices".*),
             "reports_pending_count"  = get_reports_pending_count_in_offices("offices".*)
      WHERE  "offices"."id" IN (SELECT "office_communes"."office_id" FROM "office_communes" WHERE "office_communes"."code_insee" = NEW."code_insee")
         OR  "offices"."id" IN (SELECT "office_communes"."office_id" FROM "office_communes" WHERE "office_communes"."code_insee" = OLD."code_insee");
    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
