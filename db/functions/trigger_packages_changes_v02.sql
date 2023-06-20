CREATE OR REPLACE FUNCTION trigger_packages_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all completed
    -- * on creation
    -- * when reports_count or reports_completed_count changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."reports_count" <> OLD."reports_count")
    OR (TG_OP = 'UPDATE' AND NEW."reports_completed_count" <> OLD."reports_completed_count")
    THEN

      UPDATE "packages"
      SET    "completed" = (NEW."reports_count" = NEW."reports_completed_count")
      WHERE  "packages"."id" IN (NEW."id", OLD."id")
        AND NEW."reports_count" <> 0;

    END IF;

    -- Reset all packages counts on publishers & collectivities
    -- * on creation
    -- * on deletion
    -- * when sandbox changed
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when (transmitted_at|approved_at|rejected_at|discarded_at) changed from NULL
    -- * when (transmitted_at|approved_at|rejected_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" <> OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND ((NEW."publisher_id" IS NULL) <> (OLD."publisher_id" IS NULL) OR (NEW."publisher_id" <> OLD."publisher_id")))
    OR (TG_OP = 'UPDATE' AND (NEW."transmitted_at" IS NULL) <> (OLD."transmitted_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "packages_count"          = get_packages_count_in_publishers("publishers".*),
             "packages_approved_count" = get_packages_approved_count_in_publishers("publishers".*),
             "packages_rejected_count" = get_packages_rejected_count_in_publishers("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

      UPDATE "collectivities"
      SET    "packages_transmitted_count" = get_packages_transmitted_count_in_collectivities("collectivities".*),
             "packages_approved_count"    = get_packages_approved_count_in_collectivities("collectivities".*),
             "packages_rejected_count"    = get_packages_rejected_count_in_collectivities("collectivities".*),
             "reports_transmitted_count"  = get_reports_transmitted_count_in_collectivities("collectivities".*),
             "reports_approved_count"     = get_reports_approved_count_in_collectivities("collectivities".*),
             "reports_rejected_count"     = get_reports_rejected_count_in_collectivities("collectivities".*),
             "reports_debated_count"      = get_reports_debated_count_in_collectivities("collectivities".*)
      WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
