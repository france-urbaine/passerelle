CREATE OR REPLACE FUNCTION trigger_packages_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all packages and reports counts on organizations & offices
    -- * on creation
    -- * on deletion
    -- * when sandbox changed
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when (approved_at|returned_at|discarded_at) changed from NULL
    -- * when (approved_at|returned_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" <> OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id"))
    OR (TG_OP = 'UPDATE' AND (NEW."assigned_at" IS NULL) <> (OLD."assigned_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."returned_at" IS NULL) <> (OLD."returned_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "packages_transmitted_count" = get_publishers_packages_transmitted_count("publishers".*),
             "packages_assigned_count"    = get_publishers_packages_assigned_count("publishers".*),
             "packages_returned_count"    = get_publishers_packages_returned_count("publishers".*),
             "reports_transmitted_count"  = get_publishers_reports_transmitted_count("publishers".*),
             "reports_approved_count"     = get_publishers_reports_approved_count("publishers".*),
             "reports_rejected_count"     = get_publishers_reports_rejected_count("publishers".*),
             "reports_debated_count"      = get_publishers_reports_debated_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

      UPDATE "collectivities"
      SET    "packages_transmitted_count" = get_collectivities_packages_transmitted_count("collectivities".*),
             "packages_unresolved_count"  = get_collectivities_packages_unresolved_count("collectivities".*),
             "packages_assigned_count"    = get_collectivities_packages_assigned_count("collectivities".*),
             "packages_returned_count"    = get_collectivities_packages_returned_count("collectivities".*),
             "reports_packing_count"      = get_collectivities_reports_packing_count("collectivities".*),
             "reports_transmitted_count"  = get_collectivities_reports_transmitted_count("collectivities".*),
             "reports_returned_count"     = get_collectivities_reports_returned_count("collectivities".*),
             "reports_pending_count"      = get_collectivities_reports_pending_count("collectivities".*),
             "reports_debated_count"      = get_collectivities_reports_debated_count("collectivities".*),
             "reports_approved_count"     = get_collectivities_reports_approved_count("collectivities".*),
             "reports_rejected_count"     = get_collectivities_reports_rejected_count("collectivities".*)
      WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

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
      WHERE  "ddfips"."code_departement" IN (
        SELECT     "communes"."code_departement"
        FROM       "communes"
        INNER JOIN "reports" ON "reports"."code_insee" = "communes"."code_insee"
        WHERE      "reports"."package_id" IN (NEW."id", OLD."id")
      );

      UPDATE "offices"
      SET    "reports_assigned_count" = get_offices_reports_assigned_count("offices".*),
             "reports_pending_count"  = get_offices_reports_pending_count("offices".*),
             "reports_debated_count"  = get_offices_reports_debated_count("offices".*),
             "reports_approved_count" = get_offices_reports_approved_count("offices".*),
             "reports_rejected_count" = get_offices_reports_rejected_count("offices".*)
      WHERE  "offices"."id" IN (
                SELECT     "office_communes"."office_id"
                FROM       "office_communes"
                INNER JOIN "reports" ON "reports"."code_insee" = "office_communes"."code_insee"
                WHERE      "reports"."package_id" IN (NEW."id", OLD."id")
             );

      UPDATE "dgfips"
      SET    "packages_transmitted_count" = get_dgfips_packages_transmitted_count("dgfips".*),
             "packages_assigned_count"    = get_dgfips_packages_assigned_count("dgfips".*),
             "packages_returned_count"    = get_dgfips_packages_returned_count("dgfips".*),
             "reports_transmitted_count"  = get_dgfips_reports_transmitted_count("dgfips".*),
             "reports_returned_count"     = get_dgfips_reports_returned_count("dgfips".*),
             "reports_pending_count"      = get_dgfips_reports_pending_count("dgfips".*),
             "reports_debated_count"      = get_dgfips_reports_debated_count("dgfips".*),
             "reports_approved_count"     = get_dgfips_reports_approved_count("dgfips".*),
             "reports_rejected_count"     = get_dgfips_reports_rejected_count("dgfips".*);

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
