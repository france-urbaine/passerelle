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
    -- * when (discarded_at) changed from NULL
    -- * when (discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" <> OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id"))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "reports_transmitted_count" = get_publishers_reports_transmitted_count("publishers".*),
             "reports_approved_count"    = get_publishers_reports_approved_count("publishers".*),
             "reports_rejected_count"    = get_publishers_reports_rejected_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

      UPDATE "collectivities"
      SET    "reports_packing_count"     = get_collectivities_reports_packing_count("collectivities".*),
             "reports_transmitted_count" = get_collectivities_reports_transmitted_count("collectivities".*),
             "reports_denied_count"      = get_collectivities_reports_denied_count("collectivities".*),
             "reports_processing_count"  = get_collectivities_reports_processing_count("collectivities".*),
             "reports_approved_count"    = get_collectivities_reports_approved_count("collectivities".*),
             "reports_rejected_count"    = get_collectivities_reports_rejected_count("collectivities".*)
      WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

      UPDATE "ddfips"
      SET    "reports_transmitted_count" = get_ddfips_reports_transmitted_count("ddfips".*),
             "reports_denied_count"      = get_ddfips_reports_denied_count("ddfips".*),
             "reports_processing_count"  = get_ddfips_reports_processing_count("ddfips".*),
             "reports_approved_count"    = get_ddfips_reports_approved_count("ddfips".*),
             "reports_rejected_count"    = get_ddfips_reports_rejected_count("ddfips".*)
      WHERE  "ddfips"."code_departement" IN (
        SELECT     "communes"."code_departement"
        FROM       "communes"
        INNER JOIN "reports" ON "reports"."code_insee" = "communes"."code_insee"
        WHERE      "reports"."package_id" IN (NEW."id", OLD."id")
      );

      UPDATE "offices"
      SET    "reports_assigned_count"   = get_offices_reports_assigned_count("offices".*),
             "reports_processing_count" = get_offices_reports_processing_count("offices".*),
             "reports_approved_count"   = get_offices_reports_approved_count("offices".*),
             "reports_rejected_count"   = get_offices_reports_rejected_count("offices".*)
      WHERE  "offices"."id" IN (
                SELECT     "office_communes"."office_id"
                FROM       "office_communes"
                INNER JOIN "reports" ON "reports"."code_insee" = "office_communes"."code_insee"
                WHERE      "reports"."package_id" IN (NEW."id", OLD."id")
             );

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
